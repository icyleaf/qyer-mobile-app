require 'rest-client'


module QMA
  class Client
    attr_reader :config

    def initialize(key, config_file: nil)
      @key = key
      @config = load_config!(config_file)
    end

    def upload(file, host_type: :external, params: {})
      url = request_url(host_type)
      params = url_params(file, params)
      ap url
      ap params
      res = RestClient.post(url, params) do |response, request, result, &block|
        case response.code
        when 200..444
          response
        else
          response.return!(request, result, &block)
        end
      end

      case res.code
      when 200..201
        data = JSON.parse res
        data['host'] = {
          external: host(:external),
          intranet: host(:intranet),
        }

        {
          code: res.code,
          entry: data
        }
      when 400..428
        data = JSON.parse res
        {
          code: res.code,
          message: data['error'],
          entry: data['reason']
        }
      else
        {
          code: res.code,
          entry: res
        }
      end
    end

    def app_url(host, slug, version = nil)
      url_path = ['apps', slug]
      url_path.push version.to_s if version

      URI.join(host, url_path.join('/')).to_s
    end

    def url_params(file, params)
      params.merge!({
        multipart: true,
        file: File.new(file, 'rb'),
        key: @key
      })
    end

    def request_url(host_type)
      URI.join(host(host_type), upload_uri).to_s
    end

    def host(host_type = :external)
      case host_type
      when :external
        @config.external_host
      when :intranet
        @config.intranet_host
      else
        raise NotMatchedError, host_type
      end
    end

    def upload_uri
      'api/app/upload'
    end

    private

      def load_config!(config_file)
        QMA::Config.new(config_file)
      end

  end #/Client
end #/QMA