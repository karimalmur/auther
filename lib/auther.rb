# frozen_string_literal: true

Dir["./lib/utils/*.rb"].each { |f| require f }
require "auther/config"
require "auther/middleware"
require "auther/resource"
require "auther/confirmable"
require "auther/auther"

module Auther; end

Auther.configure {}
