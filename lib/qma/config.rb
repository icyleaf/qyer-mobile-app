require 'yaml'

module QMA
  class Config
    attr_reader :path, :data

    def initialize(path = nil)
      if path.to_s.empty?
        load_default_config
      else
        raise QMA::NotFoundError, path unless File.exist?(path)
        load(path)
      end

      migratate_old_data if old_data?
    end

    def key
      @data.try(:[], 'key')
    end

    def key=(key)
      @data['key'] = key
    end

    def hosts
      @data.try(:[], 'host')
    end

    def external_host
      @data.try(:[], 'host').try(:[], 'external')
    end

    def intranet_host
      @data.try(:[], 'host').try(:[], 'intranet')
    end

    def hosts=(host)
      self.external_host = host
      self.intranet_host = host
    end

    def external_host=(host)
      update_host('external', host)
    end

    def intranet_host=(host)
      update_host('intranet', host)
    end

    def load(path)
      @path = path
      @data ||= YAML.load(File.open(@path))
      load_to_env
    end

    def load_default_config
      FileUtils.cp template_config_file, default_path unless File.exist?(default_path)
      load(default_path)
    end

    def save
      File.open(@path, 'w') do |f|
        f.write @data.to_yaml
      end

      self
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
      File.join(source_path, 'qma.yml')
    end

    def load_to_env
      ENV['QMA_KEY'] = key
      ENV['QMA_EXTERNAL_HOST'] = external_host
      ENV['QMA_INTRANET_HOST'] = intranet_host
    end

    def update_host(type, host)
      @data['host'] = {} unless @data.key?('host')
      @data['host'][type.to_s] = host
    end

    def old_data?
      @data.key?('development') || @data.key?('production')
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
  end # /Config
end # /QMA
