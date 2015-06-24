require 'yaml'
require 'awesome_print'


command :config do |c|
  c.syntax = 'qma init'
  c.summary = '配置命令需求的参数'
  c.description = '配置命令需求的参数 (路径: ~/.qma)'

  c.option '--list', '显示当前配置信息'
  c.option '--host HOST', '当前环境 HOST'
  c.option '--[no-]overwrite', '强行覆盖配置文件'

  c.action do |args, options|
    @host = options.host || nil
    @overwrite = options.overwrite
    @list = options.list

    @configuration_file = File.join(File.expand_path('~'), '.qma')

    determine_qyer_env!

    if @list
      list_configuration_file!
    elsif  @host || @overwrite
      generate_configuration_file!
    else
      say_error "使用 --help 查看帮助"
    end
  end

  private

    def generate_configuration_file!
      data = {
        ENV['QYER_ENV'].downcase.to_sym => {
          'host' => @host
        }
      }

      if ! determine_default_configuration_file! || @overwrite
        File.open(@configuration_file, 'wb') do |file|
          file.write data.to_yaml
        end

        say_ok "配置更新成功"
        list_configuration_file!
      else
        say_error "配置已存在无法覆盖，如需强制更新附加 --overwrite 参数"
      end
    end

    def list_configuration_file!
      say_warning '显示配置...' if $verbose

      if determine_default_configuration_file!
        ap YAML.load(File.open(@configuration_file))
      else
        say_error "没有配置文件"
      end
    end

    def determine_default_configuration_file!
      say_warning '检测配置文件...' if $verbose

      File.exists?(@configuration_file)
    end

    def determine_qyer_env!
      say_warning "QYER_ENV = #{ENV['QYER_ENV']}" if $verbose

      envs = %w[development test production]
      unless envs.include?ENV['QYER_ENV']
        say_error "无效环境，仅限如下：#{envs.join(', ')}" and abort
      end
    end
end
