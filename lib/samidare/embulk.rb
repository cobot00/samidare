module Samidare
  class Embulk
    def run(database_configs, all_table_configs, bq_config, target_table_names = [])
      error_tables = []
      database_configs.keys.each do |db_name|
        table_configs = target_table_configs(all_table_configs[db_name], target_table_names)
        error_tables = error_tables + run_by_database(
          db_name,
          table_configs,
          database_configs[db_name]['bq_dataset'],
          bq_config)
      end
      error_tables
    end

    def target_table_configs(table_configs, target_table_names)
      return table_configs if target_table_names.empty?
      table_configs.select { |table_config| target_table_names.include?(table_config.name) }
    end

    private
    def run_by_database(db_name, table_configs, bq_dataset, bq_config)
      process_times = []
      error_tables = []
      big_query = Samidare::BigQueryUtility.new(bq_config)
      table_configs.each do |table_config|
        start_time = Time.now
        log "table: #{table_config.name} - start"

        begin
          big_query.delete_table(bq_dataset, table_config.name)
          log "table: #{table_config.name} - deleted"
        rescue
          log "table: #{table_config.name} - does not exist"
        end

        cmd = "embulk run #{bq_config['config_dir']}/#{db_name}/#{table_config.name}.yml"
        log "cmd: #{cmd}"
        if system(cmd)
          result = 'success'
        else
          result = 'error'
          error_tables << table_config.name
        end

        process_time = "table: #{table_config.name} - result: #{result}  #{sprintf('%10.1f', Time.now - start_time)}sec"
        log process_time
        process_times << process_time
      end
      log '------------------------------------'
      log "db_name: #{db_name}"
      process_times.each { |process_time| log process_time }

      error_tables
    end

    def log(message)
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
    end
  end
end