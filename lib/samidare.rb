require 'samidare/version'
require 'samidare/embulk_utility'

module Samidare
  class EmbulkClient
    def generate_config(config)
      Samidare::EmbulkUtility::ConfigGenerator.new(config).generate_config
    end

    def run(config, target_tables = [])
      db_infos = Samidare::EmbulkUtility::DBInfo.generate_db_infos
      table_infos = Samidare::EmbulkUtility::TableInfo.generate_table_infos
      db_infos.keys.each do |db_name|
        embulk_run(db_name, db_infos[db_name]['bq_dataset'], table_infos[db_name], config, target_tables)
      end
    end

    private
    def embulk_run(db_name, bq_dataset, tables, config, target_tables)
      process_times = []
      big_query = Samidare::BigQueryUtility.new(config)
      tables.each do |table|
        next unless target_table?(table.name, target_tables)

        start_time = Time.now
        log "table: #{table.name} - start"

        begin
          big_query.delete_table(bq_dataset, table.name)
          log "table: #{table.name} - deleted"
        rescue
          log "table: #{table.name} - does not exist"
        end

        cmd = "embulk run #{config['config_dir']}/#{db_name}/#{table.name}.yml"
        log "cmd: #{cmd}"
        result = system(cmd) ? 'success' : 'error'

        process_time = Time.now - start_time
        message = "table: #{table.name} - result: #{result}  #{sprintf('%10.1f', process_time)}sec"
        log message
        process_times << message
      end
      log '------------------------------------'
      log "db_name: #{db_name}"
      process_times.each { |process_time| log process_time }
    end

    def target_table?(table, target_tables)
      return true if target_tables.empty?
      target_tables.include?(table)
    end

    def log(message)
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
    end
  end
end
