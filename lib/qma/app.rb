module QMA
  class App
    class NotFoundError < StandardError; end
    class NotAppError < StandardError; end

    def self.parse(file)
      raise NotFoundError, file unless File.exist?(file)

      case File.extname(file).downcase
      when ".ipa"
        Parser::IPA.new(file)
      when ".apk"
        Parser::APK.new(file)
      else
        raise NotAppError, file
      end
    end
  end #/Parser
end #/QMA