module Samidare
  module EmbulkUtility
    class ConfigGenerator
      def generate_config(database_configs, bq_config)
        bq_utility = BigQueryUtility.new(bq_config)

        database_configs.keys.each do |db_name|
          database_config = database_configs[db_name]
          table_configs = all_table_configs[db_name]
          mysql_client = MySQL::MySQLClient.new(database_config)

          table_configs.each do |table_config|
            write(
              "#{bq_config['schema_dir']}/#{db_name}",
              "#{table_config.name}.json",
              mysql_client.generate_bq_schema(table_config.name)
            )
            write(
              "#{bq_config['config_dir']}/#{db_name}",
              "#{table_config.name}.yml",
              bq_utility.generate_embulk_config(
                db_name,
                database_config,
                table_config,
                mysql_client.columns(table_config.name))
            )
          end
        end
      end

      private
      def write(directory, file_name, content)
        FileUtils.mkdir_p(directory) unless FileTest.exist?(directory)
        File.write("#{directory}/#{file_name}", content)
      end

      def all_table_configs
        @all_table_configs ||= MySQL::TableConfig.generate_table_configs
      end
    end
  end
end
