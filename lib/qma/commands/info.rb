require 'terminal-table'

command :info do |c|
  c.syntax = 'qma info [option]'
  c.summary = '查看 app 的数据信息'
  c.description = '解析 app 的元数据并一一返回'

  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'

  c.action do |args, options|
    @file = args.first || options.file
    determine_file!

    @app = QMA::App.parse(@file)
    dump_data!
  end

  def dump_data!
    table = dump_common!
    table = dump_ipa!(table) if @app.os == 'ios'

    say table
  end

  def dump_common!
    keys = %w(name release_version build_version identifier os)
    Terminal::Table.new do |t|
      keys.each do |key|
        value = @app.send(key.to_sym)
        columns = []
        columns << key.capitalize
        columns << case value
                   when Hash
                     value.collect{|k, v| "#{k}: #{v}"}.join("\n")
                   when Array
                     value.join("\n")
                   else
                     value.to_s
                   end

        t << columns
      end
    end
  end

  def dump_ipa!(table)
    @app.mobileprovision.each do |key, value|
      next if key == 'DeveloperCertificates'

      columns = []
      columns << key
      columns << case value
                 when Hash
                   value.collect{|k, v| "#{k}: #{v}"}.join("\n")
                 when Array
                   value.join("\n")
                 else
                   value.to_s
                 end

      table << columns
    end

    table

    # t << ['Codesigned', codesigned.to_s.capitalize]
  end

  def determine_file!
    say_error "请填写应用路径(仅限 ipa/apk 文件):" && abort if @file.to_s.empty?
    say_error "输入的文件不存在" && abort unless File.exist?(@file)

    file_extname = File.extname(@file).delete('.')
    unless %w(ipa apk).include?(file_extname)
      say_error "应用仅接受 ipa/apk 文件" && abort
    end
  end
end
