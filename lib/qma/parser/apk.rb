require 'ruby_apk'
require 'image_size'

module QMA
  module Parser
    ##
    # APK 解析
    class APK
      attr_reader :file, :apk

      def initialize(file)
        @file = file
        @apk = ::Android::Apk.new(file)
      end

      def os
        'Android'
      end

      def build_version
        @apk.manifest.version_code.to_s
      end

      def release_version
        @apk.manifest.version_name
      end

      def name
        @apk.resource.find('@string/app_name')
      end

      def bundle_id
        @apk.manifest.package_name
      end

      def icons
        unless @icons
          tmp_path = File.join(Dir.mktmpdir, "qma-android-#{SecureRandom.hex}")

          @icons = @apk.icon.each_with_object([]) do |(path, data), obj|
            icon_name = File.basename(path)
            icon_path = File.join(tmp_path, File.path(path))
            icon_file = File.join(icon_path, icon_name)
            FileUtils.mkdir_p icon_path
            File.open(icon_file, 'w') do |f|
              f.write data
            end

            obj << {
              name: icon_name,
              file: icon_file,
              dimensions: ImageSize.path(icon_file).size
            }
          end
        end

        @icons
      end

      alias identifier bundle_id
    end # /APK
  end # /Parser
end # /QMA
