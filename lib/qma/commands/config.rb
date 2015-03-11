require 'yaml'

command :config do |c|
  c.syntax = 'qma init'
  c.summary = '配置命令需求的参数'
  c.description = '配置命令需求的参数 (路径: ~/.qma)'

  c.option '--devhost DEVHOST', '开发环境的 HOST'
  c.option '--prohost PROHOST', '产品环境的 HOST'
  c.option '--[no-]overwrite', '强行覆盖配置文件'

  c.action do |args, options|
    @dev_host = options.devhost || 'http://localhost:3000'
    @pro_host = options.prohost || nil
    @overwrite = options.overwrite

    @configuration_file = File.join(File.expand_path('~'), '.qma')

    determine_default_configuration_file!
    generate_configuration_file!
  end

  private

    def generate_configuration_file!
      data = {
        'development' => {
          'host' => @dev_host
        },
        'production' => {
          'host' => @pro_host
        }
      }

      File.open(@configuration_file, 'w') do |file|
        file.write data.to_yaml
      end

      say_ok "配置更新成功"
    end

    def determine_default_configuration_file!
      say_warning '检测配置文件...' if $verbose

      if File.exists?(@configuration_file) && ! @overwrite
        say_error '配置文件已存在 (#{@configuration_file})' and abort
      end
    end
end
