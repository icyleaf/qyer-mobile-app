require 'socket'

command :pac do |c|
  c.syntax = 'qma pac [option]'
  c.summary = '上报本机 IP 用于自动代理使用'
  c.description = '获取本机的 IP 信息并上传至穷游移动系统'

  c.option '--show', '显示本机 IP 信息'
  c.option '--config CONFIG', '配置文件路径 (路径: ~/.qma)'
  c.option '--id ID', '自定代理 id'
  c.option '--port PORT', '自定代理转发端口，（默认: 8080)'

  c.action do |_args, options|
    @show = options.show
    @id = options.id
    @port = options.port || 8080

    if @show
      show!
    else
      @config = QMA::Config.new(options.config.to_s)
      report!
    end
  end

  private

  def report!
    determine_id!
    return say_error '缺少 key' unless @id

    url = "#{@config.external_host}/api/v2/pacs/update"
    host = addrs[addrs.keys.first][:ipv4]
    params = {
      id: @id,
      host: host,
      port: @port,
    }

    say_warning "URL: #{url}" if $verbose
    say_warning "Params: #{params}" if $verbose
    r = RestClient.post url, params
    case r.code
    when 202
      say_ok "#{host}:#{@port} - 上报成功"
    else
      json = JSON.parse(r)
      say_error "[ERROR] #{json[:error]}"
    end
  rescue RestClient::NotModified
    say_warning "#{host}:#{@port} - 没有变更"
  rescue RestClient::ResourceNotFound => e
    abort! "[ERROR] #{e}"
  end

  def show!
    table = Terminal::Table.new do |t|
      addrs.each do |eth, ips|
        columns = []
        columns << eth.to_s
        columns << '|' * 30
        t << columns
        ips.each do |key, value|
          t << :separator
          columns = []
          columns << key.to_s
          columns << value
          t << columns
        end
      end
    end

    say table
  end

  def determine_id!
    @id ||= ask 'Pac ID:'
  end

  def addrs
    return @ip_address if @ip_address

    @ip_address ||= {}
    Socket.getifaddrs.select { |addr| addr.addr.ip? && StringScanner.new(addr.name).match?(/(?:en|eth)/i) }
          .each do |addr|
            symbol_name = addr.name.to_sym
            ip_addr = addr.addr
            @ip_address[symbol_name] ||= {} unless @ip_address.key?symbol_name
            if ip_addr.ipv4?
              @ip_address[symbol_name][:ipv4] = ip_addr.ip_address
            elsif ip_addr.ipv6?
              @ip_address[symbol_name][:ipv6] = ip_addr.ip_address
            end
          end

    @ip_address
  end
end
