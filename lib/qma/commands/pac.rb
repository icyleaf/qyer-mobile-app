require 'socket'

command :pac do |c|
  c.syntax = 'qma pac [option]'
  c.summary = '上报本机 IP 用于自动代理使用'
  c.description = '获取本机的 IP 信息并上传至穷游移动系统'

  c.option '--report', '上传本机 IP 信息'
  c.option '--config CONFIG', '配置文件路径 (路径: ~/.qma)'
  c.option '--key KEY', '自定代理 Key'
  c.option '--port PORT', '自定代理转发端口'

  c.action do |_args, options|
    @report = options.report
    @key = options.key
    @port = options.port

    if @report
      @config = QMA::Config.new(options.config.to_s)
      report!
    else
      show!
    end
  end

  private

  def report!
    determine_key!
    return say_error '缺少 key' unless @key

    section! '参数信息'
    show!

    url = "#{@config.external_host}/api/pacs/report"
    params = {
      key: @key,
      port: @port,
      hostname: hostname,
      addrs: JSON.dump(addrs)
    }

    section! '上传本地地址'
    say_warning "URL: #{url}" if $verbose
    say_warning "Params: #{params}" if $verbose
    r = RestClient.post url, params
    json = JSON.parse(r)
    if r.code == 201
      say '汇报成功'
    else
      say_error "[ERROR] #{json[:error]}"
    end
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

  def determine_key!
    @key ||= ask 'Pac Key:'
  end

  def hostname
    Socket.gethostname
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
