require 'samidare/version'
require 'samidare/embulk_utility'
require 'samidare/embulk'

module Samidare
  class EmbulkClient
    def generate_config(config)
      Samidare::EmbulkUtility::ConfigGenerator.new(config).generate_config
    end

    def run(config, target_tables = [])
      Samidare::Embulk.new.run(config, target_tables)
    end
  end
end
