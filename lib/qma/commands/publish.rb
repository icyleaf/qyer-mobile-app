require 'json'

command :publish do |c|
  @allowed_app = %w(ipa apk).freeze

  c.syntax = 'qma publish [options]'
  c.summary = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'
  c.description = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'

  # 必备参数
  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'
  c.option '-k', '--key KEY', '用户唯一的标识'
  # App 属性
  c.option '-n', '--name NAME', '设置应用名'
  c.option '-s', '--slug qSLUG', '设置或更新应用的地址标识'
  c.option '-c', '--changelog CHANGLOG', '应用更新日志'
  c.option '--branch BRANCH', 'Git 分支名'
  c.option '--commit COMMIT', 'Git 提交识别码'
  c.option '--channel CHANNEL', '上传渠道（默认：API)'
  c.option '--ci-url CI_URL', '集成 CI 的构建地址'

  # 高级
  c.option '--json-data JSON_DATA', '以 json 格式租装数据，会覆盖其他同等参数'
  c.option '--config CONFIG', '自定义配置文件 (默认: ~/.qma)'
  c.option '--host-type HOST_TYPE', '上传地址类型 (默认: external)'

  c.action do |args, options|
    options.default(
      host_type: 'external',
      channel: 'API',
      json_data: '{}'
    )

    @file = args.first || options.file
    abort!('没有找到 app 路径') unless @file && File.exist?(@file)

    @config_file = options.config
    @host_type = options.host_type.to_sym

    @name = options.name
    @user_key = options.key
    @changelog = options.changelog

    @channel = options.channel
    @branch = options.branch
    @commit = options.commit
    @ci_url = options.ci_url

    @json_data = options.json_data

    determine_file!
    determine_user_key!
    determine_json_data!

    parse_app!
    publish!
  end

  private

  def publish!
    params = common_params.merge(default_params)
    params = params.merge(@json_data) unless @json_data.empty?
    dump_basic_metedata!(params)
    client = QMA::Client.new(@user_key, config_file: @config_file)

    section! '上传应用中'
    warnning! "External URL: #{client.config.external_host}" if $verbose
    warnning! "Intranet URL: #{client.config.intranet_host}" if $verbose
    warnning! "Params: #{params}" if $verbose

    json_data = client.upload(@file, host_type: @host_type, params: params)

    parse_response(json_data)
  rescue URI::InvalidURIError => e
    abort! e.to_s
  end

  private

  def parse_response(json)
    warnning! "Response: #{json}" if $verbose
    case json[:code]
    when 201
      new_upload(json)
    when 200
      found_exist(json)
    when 400..428
      fail_valid(json)
    else
      say_error "[ERROR] #{json[:message]}"
    end
  end

  def new_upload(json)
    url = app_url(json[:entry])
    ENV['QMA_APP_URL'] = url

    info! '上传成功'
    info! url
  end

  def found_exist(json)
    url = app_url(json[:entry], true)
    ENV['QMA_APP_URL'] = url

    info! '该版本已经存在于服务器'
    info! url
  end

  def fail_valid(json)
    say_error "[ERROR] #{json[:message]}"
    json[:entry].each_with_index do |(key, items), i|
      say_warning "#{i + 1}. #{key}"
      items.each do |item|
        say_warning "- #{item}"
      end
    end unless json.empty?
  end

  def app_url(json, version = false)
    host = json['host']['external']
    slug = json['app']['slug']
    paths = [host, 'apps', slug]
    paths.push(json['id'].to_s) if version

    paths.join('/')
  end

  def dump_basic_metedata!(params)
    section! "解析 #{File.basename(@file)} 应用的内部参数"
    info! "应用: #{params[:name]}"
    info! "标识: #{params[:identifier]}"
    info! "版本: #{params[:release_version]} (#{params[:build_version]})"
    info! "类型：#{params[:device_type]}"
  end

  def common_params
    common_keys = %w(name device_type identifier release_version build_version)
    build_params(common_keys)
  end

  def build_params(keys)
    keys.each_with_object({}) do |key, obj|
      symbol_name =
        if key == 'device_type'
          :os
        else
          key.to_sym
        end

      obj[key.to_sym] = @app.send(symbol_name)
    end
  end

  def default_params
    {
      channel: @channel,
      branch: @branch,
      last_commit: @commit,
      ci_url: @ci_url,
      changelog: @changelog
    }
  end

  def parse_app!
    @app = AppInfo.parse(@file)
  end

  def determine_file!
    white_exts = %w(ipa apk).freeze
    file_extname = File.extname(@file).delete('.')

    abort! '输入的文件不存在' unless File.exist?(@file)
    abort! '应用仅接受 ipa/apk 文件' unless white_exts.include?(file_extname)
  end

  def determine_user_key!
    @user_key ||= ask 'User Key:'
  end

  def determine_json_data!
    @json_data = JSON.parse(@json_data)
  rescue JSON::ParserError
    @json_data = {}
  end

  def section!(message)
    info! "--- #{message} ---" unless $slince
  end

  def info!(message)
    say_ok "#{current_time}: #{message}" unless $slince
  end

  def warnning!(message)
    say_warning "#{current_time}: #{message}" unless $slince
  end

  def abort!(message)
    say_error "#{current_time}: #{message}" unless $slince
    abort
  end

  def current_time
    Time.now.strftime('[%H:%m:%S]')
  end
end
