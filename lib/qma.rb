require 'qma/version'
require 'qma/config'
require 'qma/client'

module QMA
  class NotFoundError < StandardError; end
  class NotAppError < StandardError; end
  class NotMatchedError < StandardError; end
end
