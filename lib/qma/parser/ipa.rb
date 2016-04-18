require "cfpropertylist"
require 'qma/core_ext/object/try'


module QMA
  module Parser
    class IPA
      attr_reader :file, :app

      def initialize(file)
        @file = file
        @app = app_path
      end

      def os
        'ios'
      end

      def build_version
        info['CFBundleVersion']
      end

      def release_version
        info['CFBundleShortVersionString']
      end

      def app_name
        display_name || name
      end

      def identifier
        info['CFBundleIdentifier']
      end

      def display_name
        info['CFBundleDisplayName']
      end

      def name
        info["CFBundleName"]
      end

      def app_path
        @app_path ||= Dir.glob(File.join(contents, 'Payload', '*.app')).first
      end

      def icons
        @icons ||= begin
          icons = []
          info['CFBundleIcons']['CFBundlePrimaryIcon']['CFBundleIconFiles'].each do |name|
            icons << get_image(name)
            icons << get_image("#{name}@2x")
          end
          icons.delete_if &:!
        rescue NoMethodError
          []
        end
      end

      def mobileprovision
        return unless has_mobileprovision?
        return @mobileprovision if @mobileprovision

        cmd = %Q{security cms -D -i "#{mobileprovision_path}"}
        begin
          @mobileprovision = CFPropertyList.native_types(CFPropertyList::List.new(data: `#{cmd}`).value)
        rescue CFFormatError
          @mobileprovision = {}
        end
      end

      def has_mobileprovision?
        File.file? mobileprovision_path
      end

      def mobileprovision_path
        @mobileprovision_path ||= File.join(@file, 'embedded.mobileprovision')
      end

      def hide_developer_certificates
        mobileprovision.delete('DeveloperCertificates') if has_mobileprovision?
      end

      def devices
        mobileprovision['ProvisionedDevices'] if has_mobileprovision?
      end

      def distribution_name
        "#{mobileprovision['Name']} - #{mobileprovision['TeamName']}" if has_mobileprovision?
      end

      def release_type
        if is_stored
          'store'
        else
          if has_mobileprovision?
            if devices
              'adhoc'
            else
              'inhouse'
            end
          end
        end
      end

      def metadata
        return unless has_metadata?
        @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
      end

      def has_metadata?
        File.file?(metadata_path)
      end

      def metadata_path
        @metadata_path ||= File.join(@contents, 'iTunesMetadata.plist')
      end

      def is_stored
        has_metadata? ? true : false
      end

      def info
        @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: File.join(app_path, 'Info.plist')).value)
      end

      def cleanup
        return unless @contents
        FileUtils.rm_rf(@contents)
        @contents = nil
      end

      alias_method :bundle_id, :identifier

      # private
        def get_image(name)
          path = File.join(@file, "#{name}.png")
          return nil unless File.exist?(path)
          path
        end

        def contents
          # 借鉴 lagunitas 解析 ipa 的代码
          # source: https://github.com/soffes/lagunitas/blob/master/lib/lagunitas/ipa.rb
          unless @contents
            @contents = "#{Dir.mktmpdir}/ios-#{SecureRandom.hex}"
            Zip::File.open(@file) do |zip_file|
              zip_file.each do |f|
                f_path = File.join(@contents, f.name)
                FileUtils.mkdir_p(File.dirname(f_path))
                zip_file.extract(f, f_path) unless File.exist?(f_path)
              end
            end
          end

          @contents
        end

        def app_icons
          Dir.mktmpdir do |dir|
            ap info.class
            info.try(:[], 'CFBundleIcons')
                .try(:[], 'CFBundlePrimaryIcon')
                .try(:[], 'CFBundleIconFiles')
                .each_with_object([]) do |icons, obj|

              Dir.glob(File.join(@contents, "#{icons}*")).find_all.each do |entry|
                ap entry
              end

            end
          end
        end

    end #/IPA
  end #/Parser
end #/QMA