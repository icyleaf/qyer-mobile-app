require 'cfpropertylist'
require 'pngdefry'
require 'fileutils'
require 'securerandom'
require 'qma/core_ext/object/try'

module QMA
  module Parser
    ##
    # 解析 IPA 文件
    class IPA
      attr_reader :file, :app_path

      def initialize(file)
        @file = file
        @app_path = app_path
      end

      def os
        'iOS'
      end

      def build_version
        info.try(:[], 'CFBundleVersion')
      end

      def release_version
        info.try(:[], 'CFBundleShortVersionString')
      end

      def identifier
        info.try(:[], 'CFBundleIdentifier')
      end

      def name
        display_name || bundle_name
      end

      def display_name
        info.try(:[], 'CFBundleDisplayName')
      end

      def bundle_name
        info.try(:[], 'CFBundleName')
      end

      def icons
        return @icons if @icons

        @icons = []
        icons_root_path.each do |name|
          info.try(:[], name)
              .try(:[], 'CFBundlePrimaryIcon')
              .try(:[], 'CFBundleIconFiles').each do |items|
                Dir.glob(File.join(app_path, "#{items}*")).find_all.each do |file|
                  dict = {
                    name: File.basename(file),
                    file: file,
                    dimensions: Pngdefry.dimensions(file)
                  }

                  @icons.push(dict)
                end
              end
        end

        @icons
      end

      def devices
        mobileprovision.try(:[], 'ProvisionedDevices')
      end

      def team_name
        mobileprovision.try(:[], 'TeamName')
      end

      def team_identifier
        mobileprovision.try(:[], 'TeamIdentifier')
      end

      def profile_name
        mobileprovision.try(:[], 'Name')
      end

      def expired_date
        mobileprovision.try(:[], 'ExpirationDate')
      end

      def distribution_name
        "#{profile_name} - #{team_name}" if profile_name && team_name
      end

      def device_type
        device_family = info.try(:[], 'UIDeviceFamily')
        if device_family.length == 1
          case device_family
          when [1]
            'iPhone'
          when [2]
            'iPad'
          end
        elsif device_family.length == 2 && device_family == [1, 2]
          'Universal'
        end
      end

      def iphone?
        device_type == 'iPhone'
      end

      def ipad?
        device_type == 'iPad'
      end

      def universal?
        device_type == 'Universal'
      end

      def release_type
        if stored?
          'Store'
        else
          build_type
        end
      end

      def build_type
        if mobileprovision?
          if devices
            'AdHoc'
          else
            'InHouse'
          end
        else
          'Debug'
        end
      end

      def hide_developer_certificates
        mobileprovision.delete('DeveloperCertificates') if mobileprovision?
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

      def mobileprovision
        return unless mobileprovision?
        return @mobileprovision if @mobileprovision

        begin
          data = `security cms -D -i "#{mobileprovision_path}"`
          @mobileprovision = CFPropertyList.native_types(CFPropertyList::List.new(data: data).value)
        rescue CFFormatError
          @mobileprovision = nil
        end
      end

      def mobileprovision?
        File.exist?mobileprovision_path
      end

      def mobileprovision_path
        filename = 'embedded.mobileprovision'
        @mobileprovision_path ||= File.join(@file, filename)
        unless File.exist?@mobileprovision_path
          @mobileprovision_path = File.join(app_path, filename)
        end

        @mobileprovision_path
      end

      def metadata
        return unless metadata?
        @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
      end

      def metadata?
        File.exist?(metadata_path)
      end

      def metadata_path
        @metadata_path ||= File.join(@contents, 'iTunesMetadata.plist')
      end

      def stored?
        metadata? ? true : false
      end

      def info
        @info ||= CFPropertyList.native_types(CFPropertyList::List.new(file: File.join(app_path, 'Info.plist')).value)
      end

      def app_path
        @app_path ||= Dir.glob(File.join(contents, 'Payload', '*.app')).first
      end

      alias bundle_id identifier

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

      def icons_root_path
        iphone = 'CFBundleIcons'.freeze
        ipad = 'CFBundleIcons~ipad'.freeze

        case device_type
        when 'iPhone'
          [iphone]
        when 'iPad'
          [ipad]
        when 'Universal'
          [iphone, ipad]
        end
      end
    end # /IPA
  end # /Parser
end # /QMA
