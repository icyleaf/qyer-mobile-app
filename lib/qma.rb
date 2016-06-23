require 'qma/version'

require 'qma/config'
require 'qma/client'
require 'qma/app'
require 'qma/parser/apk'
require 'qma/parser/ipa'

require 'qma/parser/ipa/info_plist'
require 'qma/parser/ipa/mobile_provision'

module QMA
  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end
  class NotMatchedError < StandardError; end
end
