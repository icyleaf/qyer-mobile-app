require 'qma/version'

require 'qma/config'
require 'qma/client'
require 'qma/app'
require 'qma/parser/apk'
require 'qma/parser/ipa'

require 'awesome_print'


module QMA
  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end
  class NotMatchedError < StandardError; end
end