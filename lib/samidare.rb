require 'samidare/version'
require 'samidare/embulk_utility'
require 'samidare/embulk'
require 'samidare/mysql'

module Samidare
  class EmbulkClient
    def generate_config(bq_config)
      database_configs = YAML.load_file('database.yml')
      Samidare::EmbulkUtility::ConfigGenerator.new.generate_config(database_configs, bq_config)
    end

    def run(config, target_table_names = [])
      Samidare::Embulk.new.run(config, target_table_names)
    end
  end
end
