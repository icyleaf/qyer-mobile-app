require 'yaml'


module QMA
  class Config
    attr_reader :path, :data

    def initialize(path = nil)
      if path
        raise QMA::NotFoundError, path unless File.exist?(path)
        load(path)
      else
        load_default_config
      end

      migratate_old_data if old_data?
    end

    def key
      @data['key']
    end

    def key=(key)
      @data['key'] = key
    end

    def hosts
      @data['host']
    end

    def external_host
      @data['host']['external']
    end

    def intranet_host
      @data['host']['intranet']
    end

    def hosts=(host)
      external_host = host
      intranet_host = host
    end

    def external_host=(host)
      @data['host']['external'] = host
    end

    def intranet_host=(host)
      @data['host']['intranet'] = host
    end

    def load(path)
      @path = path
      @data ||= YAML.load(File.open(@path))
    end

    def load_default_config
      FileUtils.cp template_config_file, default_path
      load(default_path)
    end

    def save
      File.open(@path, 'w') do |f|
        f.write @data.to_yaml
      end
    end

    def save!
      save
    end

    def default_path
      File.join(File.expand_path('~'), '.qma')
    end

    private

      def template_config_file
        source_path = File.expand_path('../../../config', __FILE__)
        source_file = File.join(source_path, 'qma.yml')
      end

      def old_data?
        @data.has_key?('development') || @data.has_key?('production')
      end

      def migratate_old_data
        config = Config.new(template_config_file)

        if external_host = @data.try(:[], 'production').try(:[], 'host')
          config.external_host = external_host
        else
          config.external_host = nil
        end

        if intranet_host = @data.try(:[], 'development').try(:[], 'host')
          config.intranet_host = intranet_host
        else
          config.intranet_host = nil
        end

        File.open(@path, 'w') do |f|
          f.write config.data.to_yaml
        end

        @data = config.data
      end

  end #/Config
end #/QMA