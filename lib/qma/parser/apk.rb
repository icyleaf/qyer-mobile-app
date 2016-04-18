require 'ruby_apk'

module QMA
  module Parser
    class APK
      attr_reader :file, :apk

      def initialize(file)
        @file = file
        @apk = ::Android::Apk.new(file)
      end

      def os
        'android'
      end

      def build_version
        @apk.manifest.version_code.to_s
      end

      def release_version
        @apk.manifest.version_name
      end

      def app_name
        @apk.resource.find('@string/app_name')
      end

      def bundle_id
        @apk.manifest.package_name
      end

      def icons
        @icons ||= @apk.icon.each_with_object([]) do |(name, data), obj|
          tempfile = Tempfile.new(File.basename(name))
          tempfile.binmode
          tempfile.write(data)
          tempfile.close
          size = ImageSize.path(tempfile.path).size
          obj << { dimensions: size, file_name: name }
          tempfile.unlink
        end
      end

      alias_method :identifier, :bundle_id

    end #/APK
  end #/Parser
end #/QMA