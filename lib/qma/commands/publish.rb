require 'lagunitas'
require 'awesome_print'


command :publish do |c|
  c.syntax = 'qma publish [options]'
  c.summary = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'
  c.description = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'

  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'
  c.option '-T', '--token TOKEN', '用户唯一的标识'

  c.action do |args, options|
    @file= args.first
    @user_token = options.token

    determine_file!
    determine_token!
  end

  private
    def determine_file!
      if @file.to_s.empty?
        say_error "请填写应用路径(仅限 ipa/apk 文件):" and abort
      end

      if File.exists?(@file)
        @file_extname = File.extname(@file).delete('.')
        unless %w[apk ipa].include?(@file_extname)
          say_error "应用仅接受 ipa/apk 文件" and abort
        end
      else
        say_error "输入的文件不存在" and abort
      end
    end

    def determine_token!
      if @user_token.to_s.empty?
        say_error "请填写用户凭证！" and abort
      end
    end

end
