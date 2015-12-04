module Samidare
  class Embulk
    def run(config, target_table_names = [])
      database_configs = Samidare::EmbulkUtility::DatabaseConfig.generate_database_configs
      all_table_configs = Samidare::MySQL::TableConfig.generate_table_configs

      database_configs.keys.each do |db_name|
        table_configs = target_table_configs(all_table_configs[db_name], target_table_names)
        embulk_run(db_name, database_configs[db_name]['bq_dataset'], table_configs, config)
      end
    end

    def target_table_configs(table_configs, target_table_names)
      return table_configs if target_table_names.empty?
      table_configs.select { |table_config| target_table_names.include?(table_config.name) }
    end

    private
    def embulk_run(db_name, bq_dataset, table_configs, config)
      process_times = []
      big_query = Samidare::BigQueryUtility.new(config)
      table_configs.each do |table_config|
        start_time = Time.now
        log "table: #{table_config.name} - start"

        begin
          big_query.delete_table(bq_dataset, table_config.name)
          log "table: #{table_config.name} - deleted"
        rescue
          log "table: #{table_config.name} - does not exist"
        end

        cmd = "embulk run #{config['config_dir']}/#{db_name}/#{table_config.name}.yml"
        log "cmd: #{cmd}"
        result = system(cmd) ? 'success' : 'error'

        process_time = Time.now - start_time
        message = "table: #{table_config.name} - result: #{result}  #{sprintf('%10.1f', process_time)}sec"
        log message
        process_times << message
      end
      log '------------------------------------'
      log "db_name: #{db_name}"
      process_times.each { |process_time| log process_time }
    end

    def log(message)
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
    end
  end
end