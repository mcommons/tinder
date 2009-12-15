require 'rubygems'
require 'httparty'
require 'json'
# require 'active_support'

require 'tinder/campfire'
require 'tinder/room'

module Tinder
  class Error < StandardError; end
  class SSLRequiredError < Error; end
end