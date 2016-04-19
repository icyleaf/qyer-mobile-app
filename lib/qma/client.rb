require 'rest-client'


module QMA
  class Client
    attr_reader :config, :config_file

    def initialize(key, config_file: nil)
      @config = load_config!(config_file)
    end

    private
      def load_config!(config_file)
        QMA::Config.new(config_file)
      end

  end #/Client
end #/QMA