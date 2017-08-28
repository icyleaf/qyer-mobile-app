require 'http'
require 'app-info'

module QMA
  ##
  # App 上传类
  class Client
    attr_reader :config

    def initialize(key, version: 'v2', config_file: nil, timeout: 600)
      @key = key
      @version = version
      @timeout = timeout
      @config = load_config!(config_file)
    end

    def upload(file, host_type: :intranet, params: {})
      url = request_url(host_type)
      params = url_params(file, params)

      response = HTTP.timeout(connect: @timeout, read: @timeout, write: @timeout)
                     .post(url, form: params)

      parse_response!(response)
    end

    def parse_response!(response)
      case response.code
      when 200..201
        success_response response
      when 400..500
        app_error_response response
      else
        raise response
      end
    end

    def success_response(response)
      data = response.parse(:json)
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
      data = response.parse(:json)
      {
        code: response.code,
        message: data['error'],
        entry: data['entry']
      }
    end

    def server_error_response(response)
      data = response.parse(:json)
      {
        code: response.code,
        message: data['error']
      }
    end

    def app_url(host, slug, version = nil)
      url_path = ['apps', slug]
      url_path.push version.to_s if version

      URI.join(host, url_path.join('/')).to_s
    end

    def url_params(file, params)
      params.merge!(
        icon: HTTP::FormData::File.new(params[:icon]),
        file: HTTP::FormData::File.new(file),
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
      if @version == 'v1'
        'api/app/upload'
      else
        "api/#{@version}/apps/upload"
      end
    end

    private

    def load_config!(config_file)
      QMA::Config.new(config_file)
    end
  end # /Client
end # /QMA
