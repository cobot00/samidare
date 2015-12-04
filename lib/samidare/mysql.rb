require 'mysql2-cs-bind'
require 'json'
require 'yaml'
require 'fileutils'
require 'samidare/bigquery_utility'

module Samidare
  module MySQL
    class MySQLClient
      COLUMN_SQL = <<-SQL
        SELECT column_name, data_type
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE table_schema = ?
        AND table_name = ?
        ORDER BY ordinal_position
      SQL

      def initialize(database_config)
        @database_config = database_config
      end

      def client
        @client ||= Mysql2::Client.new(
          :host => @database_config['host'],
          :username => @database_config['username'],
          :password => @database_config['password'],
          :database => @database_config['database'])
      end

      def generate_bq_schema(table_name)
        infos = columns(table_name)
        BigQueryUtility.generate_schema(infos)
      end

      def columns(table_name)
        rows = client.xquery(COLUMN_SQL, @database_config['database'], table_name)
        rows.map { |row| Column.new(row['column_name'], row['data_type']) }
      end
    end

    class TableConfig
      attr_reader :name, :daily_snapshot, :condition

      def initialize(config)
        @name = config['name']
        @daily_snapshot = config['daily_snapshot'] || false
        @condition = config['condition']
      end

      def self.generate_table_configs(file_path = 'table.yml')
        configs = YAML.load_file(file_path)
        configs.each_with_object({}) do |(db, database_config), table_configs|
          table_configs[db] = database_config['tables'].map { |config| TableConfig.new(config) }
          table_configs
        end
      end

      def ==(another)
        self.instance_variables.all? do |v|
          self.instance_variable_get(v) == another.instance_variable_get(v)
        end
      end
    end

    class Column
      attr_reader :column_name, :data_type

      TYPE_MAPPINGS = {
        'int' => 'integer',
        'tinyint' => 'integer',
        'smallint' => 'integer',
        'mediumint' => 'integer',
        'bigint' => 'integer',
        'float' => 'float',
        'double' => 'float',
        'decimal' => 'float',
        'char' => 'string',
        'varchar' => 'string',
        'tinytext' => 'string',
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
          "UNIX_TIMESTAMP(#{escaped_column_name}) AS #{escaped_column_name}"
        elsif data_type == 'tinyint'
          # for MySQL tinyint(1) problem
          "CAST(#{escaped_column_name} AS signed) AS #{escaped_column_name}"
        else
          escaped_column_name
        end
      end

      def to_json(*a)
        { "name" => @column_name, "type" => bigquery_data_type }.to_json(*a)
      end

      private
      def escaped_column_name
        "`#{@column_name}`"
      end
    end
  end
end
