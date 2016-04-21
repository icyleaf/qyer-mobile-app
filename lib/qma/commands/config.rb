command :config do |c|
  c.syntax = 'qma config [option]'
  c.summary = '配置命令需求的参数'
  c.description = '配置命令需求的参数'

  c.option '--config CONFIG', '配置文件路径 (路径: ~/.qma)'
  c.option '--host HOST', '设置穷游分发系统的域名'
  c.option '--key KEY', '设置穷游分发系统的用户 KEY'
  c.option '--type TYPE', '设置穷游分发系统的域名范围'
  c.option '-l', '--list', '显示当前配置信息 (默认显示)'
  c.option '-c', '--clear', '清除当前配置信息'

  c.action do |_args, options|
    @config = QMA::Config.new(options.config.to_s)

    if options.clear
      clear!
    elsif options.host
      update_host!(options.host, type: options.type)
    elsif options.key
      update_key!(options.key)
    else
      list!
    end
  end

  private

  def update_host!(host, type: nil)
    case type.to_s
    when 'external'
      @config.external_host = host
    when 'intranet'
      @config.intranet_host = host
    else
      @config.hosts = host
    end
    @config.save!

    list!
  end

  def update_key!(key)
    @config.key = key
    @config.save!

    list!
  end

  def list!
    table = Terminal::Table.new do |t|
      t << %w(Name Value)
      t << :separator
      t.add_row ['Key', @config.key.to_s]
      t.add_separator
      t.add_row ['External Host', @config.external_host]
      t.add_separator
      t.add_row ['Intranet Host', @config.intranet_host]
    end

    say table
  end

  def clear!
    if File.exist?(@config.path)
      File.delete @config.path
      say_ok "配置文件已清除"
    else
      say_error "没有配置文件"
    end
  end
end
