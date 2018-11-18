module RPATeachable
  class << self
    attr_accessor :user_name, :password
  end
end

require 'rpa_teachable/list'
require 'rpa_teachable/api_util'
require 'rpa_teachable/errors/authentication_error'
