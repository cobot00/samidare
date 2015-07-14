require 'mysql2-cs-bind'
require 'json'
require 'yaml'
require 'fileutils'
require 'samidare/bigquery_utility'

module Samidare
  module EmbulkUtility
    class ConfigGenerator
      def initialize(bq_config)
        @bq_config = bq_config.dup
      end

      def generate_config
        db_infos = EmbulkUtility::DBInfo.generate_db_infos
        table_infos = EmbulkUtility::TableInfo.generate_table_infos
        bq_utility = BigQueryUtility.new(@bq_config)

        db_infos.keys.each do |db_name|
          db_info = db_infos[db_name]
          table_info = table_infos[db_name]
          mysql_client = EmbulkUtility::MySQLClient.new(db_info)

          table_info.each do |table|
            write(
              "#{@bq_config['schema_dir']}/#{db_name}",
              "#{table.name}.json",
              mysql_client.generate_bq_schema(table.name)
            )
            write(
              "#{@bq_config['config_dir']}/#{db_name}",
              "#{table.name}.yml",
              bq_utility.generate_embulk_config(db_name, db_info, table, mysql_client.column_infos(table.name))
            )
          end
        end
      end

      private
      def write(directory, file_name, content)
        FileUtils.mkdir_p(directory) unless FileTest.exist?(directory)
        File.write("#{directory}/#{file_name}", content)
      end
    end

    class MySQLClient
      COLUMN_INFO_SQL = <<-SQL
        SELECT column_name, data_type
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = ?
        AND table_name = ?
        ORDER BY ordinal_position
      SQL

      def initialize(db_info)
        @db_info = db_info
      end

      def client
        @client ||= Mysql2::Client.new(
          :host => @db_info['host'],
          :username => @db_info['username'],
          :password => @db_info['password'],
          :database => @db_info['database'])
      end

      def generate_bq_schema(table_name)
        infos = column_infos(table_name)
        BigQueryUtility.generate_schema(infos)
      end

      def column_infos(table_name)
        rows = client.xquery(COLUMN_INFO_SQL, @db_info['database'], table_name)
        rows.map { |row| ColumnInfo.new(row['column_name'], row['data_type']) }
      end
    end

    class DBInfo
      attr_reader :name, :host, :username, :password, :database, :bq_dataset

      def initialize(config)
        @name = config['name']
        @host = config['host']
        @username = config['username']
        @password = config['password']
        @database = config['database']
        @bq_dataset = config['bq_dataset']
      end

      def self.generate_db_infos
        configs = YAML.load_file('database.yml')
        configs
      end
    end

    class TableInfo
      def initialize(config)
        @config = config.dup
      end

      def self.generate_table_infos
        configs = YAML.load_file('table.yml')
        configs.each_with_object({}) do |(db, db_info), table_infos|
          table_infos[db] = db_info['tables'].map { |config| TableInfo.new(config) }
          table_infos
        end
      end

      def name
        @config['name']
      end
    end

    class ColumnInfo
      attr_reader :column_name, :data_type

      TYPE_MAPPINGS = {
        'int' => 'integer',
        'tinyint' => 'integer',
        'bigint' => 'integer',
        'double' => 'float',
        'decimal' => 'float',
        'varchar' => 'string',
        'text' => 'string',
        'date' => 'timestamp',
        'datetime' => 'timestamp',
        'timestamp' => 'timestamp'
      }

      def initialize(column_name, data_type)
        @column_name = column_name
        @data_type = data_type
      end

      def bigquery_data_type
        TYPE_MAPPINGS[@data_type]
      end

      def converted_value
        if bigquery_data_type == 'timestamp'
          # time zone translate to UTC
          "UNIX_TIMESTAMP(#{@column_name}) AS #{@column_name}"
        elsif data_type == 'tinyint'
          # for MySQL tinyint(1) problem
          "CAST(#{@column_name} AS signed) AS #{@column_name}"
        else
          @column_name
        end
      end

      def to_json(*a)
        { "name" => @column_name, "type" => bigquery_data_type }.to_json(*a)
      end
    end
  end
end
