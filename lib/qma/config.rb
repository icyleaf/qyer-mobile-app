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
      source_path = File.expand_path('../../../config', __FILE__)
      source_file = File.join(source_path, 'qma.yml')
      path = File.join(File.expand_path('~'), '.qma')

      FileUtils.cp source_file, path
      load(path)
    end

    def save
      File.open(@path, 'w') do |f|
        f.write @data.to_yaml
      end
    end

    def save!
      save
      self
    end

  end #/Config
end #/QMA