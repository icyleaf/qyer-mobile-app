require 'faraday'
require 'faraday_middleware'
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
      params = parse_params(file, params)

      conn = Faraday.new(url) do |builder|
        builder.request :multipart
        builder.request :url_encoded
        builder.response :json, content_type: /\bjson$/
        builder.use FaradayMiddleware::FollowRedirects

        builder.adapter :net_http
      end

      response = conn.post do |req|
        req.options.timeout = @timeout
        req.body = params
      end

      parse_response!(response)
    end

    def request_url(host_type)
      File.join(host(host_type), upload_uri)
    end

    private

    def parse_response!(response)
      case response.status
      when 200..201
        success_response response
      when 400..600
        app_error_response response
      else
        server_error_response response
      end
    end

    def success_response(response)
      data = response.body
      data['host'] = {
        'external' => host(:external),
        'intranet' => host(:intranet)
      }

      {
        code: response.status,
        entry: data
      }
    end

    def app_error_response(response)
      data = response.body
      {
        code: response.status,
        message: data['error'],
        entry: data['entry']
      }
    rescue
      {
        code: response.status,
        message: '返回数据是无效 json 数据',
        entry: response.body
      }
    end

    def server_error_response(response)
      data = response.body
      {
        code: response.status,
        message: data['error'],
        entry: data
      }
    rescue
      {
        code: response.status,
        message: '返回数据是无效 json 数据',
        entry: response.body
      }
    end

    def app_url(host, slug, version = nil)
      url_path = ['apps', slug]
      url_path.push version.to_s if version

      URI.join(host, url_path.join('/')).to_s
    end

    def parse_params(file, params)
      params.merge!(
        icon: Faraday::UploadIO.new(params[:icon], 'image/png'),
        file: Faraday::UploadIO.new(file, 'application/octet-stream'),
        key: @key
      )
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
      "api/#{@version}/apps/upload"
    end

    private

    def load_config!(config_file)
      QMA::Config.new(config_file)
    end
  end # /Client
end # /QMA
