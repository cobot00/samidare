require 'json'
require 'erb'
require 'big_query'

module Samidare
  class BigQueryUtility
    def initialize(config)
      @config = config.dup
    end

    def self.generate_schema(column_infos)
      json_body = column_infos.map { |column_info| column_info.to_json }.join(",\n")
      "[\n" + json_body + "\n]\n"
    end

    def self.generate_sql(table_name, column_infos)
      columns = column_infos.map { |column_info| column_info.converted_value }
      sql = "SELECT " + columns.join(",")
      sql << " FROM #{table_name}\n"
    end

    def generate_embulk_config(db_name, db_info, table_info, column_infos)
      host = db_info['host']
      user = db_info['username']
      password = db_info['password']
      database = db_info['database']
      query = Samidare::BigQueryUtility.generate_sql(table_info.name, column_infos)
      project = @config['project_name']
      p12_keyfile_path = @config['key']
      service_account_email = @config['service_email']
      dataset = db_info['bq_dataset']
      table_name = table_info.name
      schema_path = "#{@config['schema_dir']}/#{db_name}/#{table_info.name}.json"
      path_prefix = "/var/tmp/embulk_#{db_name}_#{table_info.name}"

      File.open('lib/samidare/embulk_config.erb') { |f| ERB.new(f.read).result(binding) }
    end

    def delete_table(dataset, table_name)
      @config['dataset'] = dataset

      bq = BigQuery::Client.new(@config)
      bq.delete_table(table_name)
    end
  end
end
