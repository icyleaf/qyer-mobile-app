require "cfpropertylist"
require "pngdefry"
require 'qma/core_ext/object/try'
require 'fileutils'

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

      def icons
        @icons ||= info.try(:[], 'CFBundleIcons')
            .try(:[], 'CFBundlePrimaryIcon')
            .try(:[], 'CFBundleIconFiles')
            .each_with_object([]) do |icons, obj|

          Dir.glob(File.join(app_path, "#{icons}*")).find_all.each do |file|
            obj << {
              name: File.basename(file),
              file: file,
              dimensions: Pngdefry.dimensions(file),
            }
          end
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

      def device_type
        if info['UIDeviceFamily'].length == 1
          case info['UIDeviceFamily']
          when 1
            'iphone'
          when 2
            'ipad'
          end
        elsif info['UIDeviceFamily'].length == 2 && info['UIDeviceFamily'] == [1, 2]
          'universal'
        end
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
          else
            'debug'
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

      def app_path
        @app_path ||= Dir.glob(File.join(contents, 'Payload', '*.app')).first
      end

      def cleanup!
        return unless @contents
        FileUtils.rm_rf(@contents)

        @contents = nil
        @icons = nil
        @app_path = nil
        @metadata = nil
        @metadata_path = nil
        @info = nil
      end

      alias_method :bundle_id, :identifier

      private

        def contents
          # 借鉴 lagunitas 解析 ipa 的代码
          # source: https://github.com/soffes/lagunitas/blob/master/lib/lagunitas/ipa.rb
          unless @contents
            @contents = "#{Dir.mktmpdir}/qma-ios-#{SecureRandom.hex}"
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

    end #/IPA
  end #/Parser
end #/QMA