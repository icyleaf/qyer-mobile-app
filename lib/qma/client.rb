require 'rest-client'

module QMA
  ##
  # App 上传类
  class Client
    attr_reader :config

    def initialize(key, config_file: nil)
      @key = key
      @config = load_config!(config_file)
    end

    def upload(file, host_type: :intranet, params: {})
      url = request_url(host_type)
      params = url_params(file, params)

      res = RestClient.post(url, params) do |response, request, result, &block|
        case response.code
        when 200..444
          response
        else
          response.return!(request, result, &block)
        end
      end

      parse_response! res
    end

    def parse_response!(response)
      case response.code
      when 200..201
        success_response response
      when 400..428
        app_error_response response
      else
        server_error_response response
      end
    end

    def success_response(response)
      data = JSON.parse response
      data['host'] = {
        'external' => host(:external),
        'intranet' => host(:intranet)
      }

      {
        code: response.code,
        entry: data
      }
    end

    def app_error_response(response)
      data = JSON.parse response
      {
        code: response.code,
        message: data['error'],
        entry: data['reason']
      }
    end

    def server_error_response(response)
      {
        code: response.code,
        entry: response
      }
    end

    def app_url(host, slug, version = nil)
      url_path = ['apps', slug]
      url_path.push version.to_s if version

      URI.join(host, url_path.join('/')).to_s
    end

    def url_params(file, params)
      params.merge!(
        multipart: true,
        file: File.new(file, 'rb'),
        key: @key
      )
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
  end # /Client
end # /QMA
