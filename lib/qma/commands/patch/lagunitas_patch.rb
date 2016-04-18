require 'lagunitas'
require 'date'


module QMA
  class IPA < Lagunitas::IPA
    def app
      @app ||= App.new(app_path)
    end

    def metadata
      return unless has_metadata?
      @metadata ||= CFPropertyList.native_types(CFPropertyList::List.new(file: metadata_path).value)
    end

    def has_metadata?
      File.file? metadata_path
    end

    def metadata_path
      @metadata_path ||= File.join(@contents, 'iTunesMetadata.plist')
    end

    def release_type
      has_metadata? ? 'store' : 'adhoc'
    end
  end

  class App < Lagunitas::App
    def name
      info['CFBundleName']
    end

    def mobileprovision
      return unless has_mobileprovision?
      return @mobileprovision if @mobileprovision

      begin
        data = `openssl smime -inform der -verify -noverify -in #{mobileprovision_path}`
        @mobileprovision = CFPropertyList.native_types(CFPropertyList::List.new(data: data).value)
      rescue CFFormatError
        @mobileprovision = {}
      end
    end

    def has_mobileprovision?
      File.file? mobileprovision_path
    end

    def mobileprovision_path
      @mobileprovision_path ||= File.join(@path, 'embedded.mobileprovision')
    end

    def hide_developer_certificates
      mobileprovision.delete('DeveloperCertificates')
    end

    def devices
      mobileprovision['ProvisionedDevices']
    end

    def distribution_name
      "#{mobileprovision['Name']} - #{mobileprovision['TeamName']}" if has_mobileprovision?
    end

    def team_name
      mobileprovision['TeamName']
    end

    def team_identifier
      mobileprovision['TeamIdentifier']
    end

    def profile_name
      mobileprovision['Name']
    end

    def expired_date
      mobileprovision['ExpirationDate']
    end

    def release_type
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
end
