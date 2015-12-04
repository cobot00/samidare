module Samidare
  class Embulk
    def run(config, target_table_names = [])
      db_infos = Samidare::EmbulkUtility::DBInfo.generate_db_infos
      table_infos = Samidare::EmbulkUtility::TableInfo.generate_table_infos

      db_infos.keys.each do |db_name|
        tables = target_tables(table_infos[db_name], target_table_names)
        embulk_run(db_name, db_infos[db_name]['bq_dataset'], tables, config)
      end
    end

    def target_tables(tables, target_table_names)
      return tables if target_table_names.empty?
      tables.select { |table| target_table_names.include?(table.name) }
    end

    private
    def embulk_run(db_name, bq_dataset, tables, config)
      process_times = []
      big_query = Samidare::BigQueryUtility.new(config)
      tables.each do |table|
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

    def log(message)
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}"
    end
  end
end