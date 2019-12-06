# frozen_string_literal: true

Dir["./lib/utils/*.rb"].each { |f| require f }
require "auther/config"
require "auther/request_context"
require "auther/middleware"
require "auther/model/resource"
require "auther/model/confirmable"
require "auther/authentication/authentication"
require "auther/authentication/strategies/base"
require "auther/authentication/strategies/password_strategy"
require "auther/auther"

module Auther; end

Auther.configure {}
