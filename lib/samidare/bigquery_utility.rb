require 'json'
require 'erb'
require 'big_query'
require 'unindent'
require 'date'

module Samidare
  class BigQueryUtility
    CONTENTS = <<-EOS.unindent
    in:
      type: mysql
      user: <%= user %>
      password: <%= password %>
      database: <%= database %>
      host: <%= host %>
      query: |
        <%= query %>
    out:
      type: bigquery
      project: <%= project %>
      p12_keyfile_path: <%= p12_keyfile_path %>
      service_account_email: <%= service_account_email %>
      dataset: <%= dataset %>
      table: <%= table_name %>
      schema_path: <%= schema_path %>
      auto_create_table: 1
      path_prefix: <%= path_prefix %>
      source_format: NEWLINE_DELIMITED_JSON
      file_ext: .json.gz
      delete_from_local_when_job_end: 1
      formatter:
        type: jsonl
      encoders:
      - {type: gzip}
    EOS

    def initialize(config)
      @config = config.dup
      @current_date = Date.today
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
      project = @config['project_id']
      p12_keyfile_path = @config['key']
      service_account_email = @config['service_email']
      dataset = db_info['bq_dataset']
      table_name = actual_table_name(table_info.name, db_info['daily_snapshot'] || table_info.daily_snapshot)
      schema_path = "#{@config['schema_dir']}/#{db_name}/#{table_info.name}.json"
      path_prefix = "/var/tmp/embulk_#{db_name}_#{table_info.name}"

      ERB.new(CONTENTS).result(binding)
    end

    def delete_table(dataset, table_name)
      @config['dataset'] = dataset

      bq = BigQuery::Client.new(@config)
      bq.delete_table(table_name)
    end

    def actual_table_name(table_name, daily_snapshot)
      return table_name unless daily_snapshot
      table_name + @current_date.strftime('%Y%m%d')
    end
  end
end
