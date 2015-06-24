require 'yaml'
require 'awesome_print'


command :config do |c|
  c.syntax = 'qma config [option]'
  c.summary = '配置命令需求的参数'
  c.description = '配置命令需求的参数 (路径: ~/.qma)'

  c.option '-l', '--list', '显示当前配置信息'
  c.option '-c', '--clear', '清除当前配置信息'
  c.option '--host HOST', '当前环境的服务地址'
  c.option '--env ENV', '设置环境 (默认 development)'
  c.option '--[no-]overwrite', '强行覆盖配置文件'

  c.action do |args, options|
    @overwrite = options.overwrite
    @list = options.list
    @clear = options.clear

    @configuration_file = File.join(File.expand_path('~'), '.qma')

    if @list
      list_configuration_file!
    elsif @clear
      clear_configuration_file!
    elsif options.host || @overwrite
      @host = options.host
      @env = options.env || ENV['QYER_ENV'] || 'development'
      @env = @env.downcase.to_sym

      determine_qyer_env!
      generate_configuration_file!
    else
      say_error "使用 --help 查看帮助"
    end
  end

  private

    def generate_configuration_file!
      exist_data = {}
      if determine_default_configuration_file!
        AppConfig.setup!(yaml: @configuration_file, env: @env.to_sym)

        if @host && AppConfig.host && ! @overwrite
          say_error "配置已存在无法覆盖，如需强制更新附加 --overwrite 参数" and abort
        end

        exist_data = YAML.load(File.open(@configuration_file))
      end

      new_data = {
        @env.to_s => {
          'host' => @host
        }
      }

      data = exist_data.merge new_data
      File.open(@configuration_file, 'w') do |file|
        file.write data.to_yaml
      end

      say_ok "配置更新成功"
      list_configuration_file!
    end

    def list_configuration_file!
      say_warning '显示配置...' if $verbose

      if determine_default_configuration_file!
        ap YAML.load(File.open(@configuration_file))
      else
        say_error "没有配置文件"
      end
    end

    def clear_configuration_file!
      if determine_default_configuration_file!
        File.delete @configuration_file
        say_ok "配置文件已清除"
      else
        say_error "没有配置文件"
      end
    end

    def determine_default_configuration_file!
      File.exists?(@configuration_file)
    end

    def determine_qyer_env!
      say_warning "使用环境: #{@env}" if $verbose

      envs = [:development, :test, :production]
      unless envs.include?@env
        say_error "无效环境，仅限如下：#{envs.join(', ')}" and abort
      end
    end
end
