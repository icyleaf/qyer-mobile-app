command :publish do |c|
  @allowed_app = %w(ipa apk).freeze

  c.syntax = 'qma publish [options]'
  c.summary = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'
  c.description = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'

  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'
  c.option '-n', '--name NAME', '设置应用名'
  c.option '-k', '--key KEY', '用户唯一的标识'
  c.option '-s', '--slug qSLUG', '设置或更新应用的地址标识'
  c.option '-c', '--changelog CHANGLOG', '应用更新日志'
  c.option '--channel CHANNEL', '上传渠道（默认：API)'
  c.option '--branch BRANCH', 'Git 分支名'
  c.option '--commit COMMIT', 'Git 提交识别码'
  c.option '--ci-url CI_URL', '集成 CI 的构建地址'

  c.option '--env ENV', '设置环境 (默认 development)'
  c.option '--config CONFIG', '自定义配置文件 (默认: ~/.qma)'

  c.action do |args, options|
    @file = args.first || options.file
    @name = options.name
    @user_key = options.key
    @changelog = options.changelog

    @channel = options.channel || 'API'
    @branch = options.branch
    @commit = options.commit
    @ci_url = options.ci_url

    @env = options.env || ENV['QYER_ENV'] || 'development'
    @env = @env.downcase.to_sym if @env

    @config_file = options.config

    determine_qyer_env!
    determine_configuration_file!
    determine_file!
    determine_user_key!

    parse!
    publish!
  end

  private

  def publish_app(params)
    say "组装上传数据..."
    say "-> 应用: #{params[:name]}"
    say "-> 标识: #{params[:identifier]}"
    say "-> 版本: #{params[:release_version]} (#{params[:build_version]})"
    say "-> 类型：#{params[:device_type]}"

    default_params = {
      multipart: true,
      file: File.new(@file, 'rb'),
      key: @user_key,
      changelog: @changelog
    }

    params.merge!(default_params)
    url = URI.join(AppConfig.host, 'api/app/upload').to_s

    begin
      say "上传应用中"
      say_warning "API: #{url}" if $verbose
      say_warning "params: #{params}" if $verbose

      res = RestClient.post(url, params) do |response, request, result, &block|
        case response.code
        when 200..444
          response
        else
          response.return!(request, result, &block)
        end
      end

      data = JSON.parse res
      case res.code
      when 201
        url = URI.join(AppConfig.host, '/apps/', data['app']['slug']).to_s
        say "新版本上传成功"
        say url
      when 200
        url = URI.join(AppConfig.host, '/apps/', "#{data['app']['slug']}/", data['version'].to_s).to_s
        say "该版本之前已上传"
        say url
      when 400..428
        say "[#{res.code}] #{data['error']}"
        if data['reason'].count > 0
          data['reason'].each do |key, message|
            say " * #{key} #{message}"
          end
        end
      end
    rescue RestClient::Exception => e
      say "[ERROR] #{e}"
    end
  end

  def parse!
    say "解析 #{@file_extname} 应用的内部参数..." if $verbose
    @app = QMA::Parser.new(file)
  end

  def publish!
    publish_app(common_params.merge(default_params))
  end

  private

  def common_params
    common_keys = %w(name device_type identifier release_version build_version)
    build_params(common_keys)
  end

  def build_params(keys)
    keys.each_with_object([]) do |key, obj|
      obj[key] << @app.send(key.to_sym)
    end
  end

  def default_params
    {
      channel: @channel,
      branch: @branch,
      last_commit: @commit,
      ci_url: @ci_url
    }
  end

  def publish_ipa!(params)
    @name ||= app.display_name || app.name

    publish_app({
      name: @name,
      release_type: @app.release_type,
      identifier: @app.identifier,
      release_version: @app.short_version,
      build_version: @app.version,
      profile_name: app.profile_name,
      team_name: @app.team_name,
      device_type: @app.os
    }.merge(params))
  end

  def publish_apk!(params)
    publish_app({
      name: @name,
      identifier: @app.manifest.package_name,
      release_version: @app.manifest.version_name,
      build_version: @app.manifest.version_code
    }.merge(params))
  end

  def determine_configuration_file!
    say_warning '检测配置文件...' if $verbose

    if @config_file.to_s.empty? || ! File.exist?(@config_file)
      say_error '配置文件不存在 (默认: ~/.qma)' && abort
    end
  end

  def determine_file!
    say_error "请填写应用路径(仅限 ipa/apk 文件):" && abort if @file.to_s.empty?

    if File.exist?(@file)
      @file_extname = File.extname(@file).delete('.')
      unless @allowed_app.include?(@file_extname)
        say_error "应用仅接受 ipa/apk 文件" && abort
      end
    else
      say_error "输入的文件不存在" && abort
    end
  end

  def determine_user_key!
    @user_key ||= ask 'User Token:'
  end
end
