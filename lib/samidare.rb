require 'samidare/version'
require 'samidare/embulk_utility'
require 'samidare/embulk'
require 'samidare/mysql'

module Samidare
  class EmbulkClient
    def generate_config(bq_config)
      Samidare::EmbulkUtility::ConfigGenerator.new.generate_config(database_configs, bq_config)
    end

    def run(bq_config, target_table_names = [])
      error_tables = Samidare::Embulk.new.run(
        database_configs,
        Samidare::MySQL::TableConfig.generate_table_configs,
        bq_config,
        target_table_names)
      # return batch status(true: all tables success)
      error_tables.size == 0
    end

    private
    def database_configs
      YAML.load_file('database.yml')
    end
  end
end
