command :info do |c|
  c.syntax = 'qma info [option]'
  c.summary = '查看 app 的数据信息'
  c.description = '解析 app 的元数据（ipa 还会返回更多有用信息）'

  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'

  c.action do |args, options|
    @file = args.first || options.file
    determine_file!

    @app = QMA::App.parse(@file)
    dump_data!
  end

  private

  def dump_data!
    table = dump_common!
    table = dump_ipa!(table) if @app.os == 'iOS'

    say table
  end

  def dump_common!
    keys = %w(name release_version build_version identifier os)
    Terminal::Table.new do |t|
      keys.each do |key|
        columns = []
        columns << key.capitalize
        columns << @app.send(key.to_sym).to_column

        t << columns
      end
    end
  end

  def dump_ipa!(table)
    return table unless @app.mobileprovision? && !@app.mobileprovision.nil?

    @app.mobileprovision.each do |key, value|
      next if key == 'DeveloperCertificates'

      name =
        case value
        when Array
          value.size > 1 ? "#{key} (#{value.size})" : key
        when Hash
          value.keys.size > 1 ? "#{key} (#{value.keys.size})" : key
        else
          key
        end

      columns = []
      columns << name
      columns << value.to_column

      table << columns
    end

    table
  end

  def determine_file!
    abort! '请指定文件路径' if @file.to_s.empty?

    white_exts = %w(ipa apk).freeze
    abort! '指定文件不存在' unless File.exist?(@file)

    file_extname = File.extname(@file).delete('.')
    abort! '应用仅接受 ipa/apk 文件' unless white_exts.include?(file_extname)
  end

  def abort!(message)
    say_error message
    abort
  end
end
