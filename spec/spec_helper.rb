# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__)))

require "auther"
require "rubygems"
require "rack"

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

RSpec.configure do |config|
  config.include(Auther::Spec::Helpers)
  config.include(Auther::Spec::Helpers::Mock)
end
