# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__)))

require "simplecov"
require "dry/monads"
require "pry"
require "rubygems"
require "rack"
require "with_model"

SimpleCov.start do
  add_filter "/spec/"
end

require "auther"
require "auther/util/encryption"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":auther:"

Dir[File.join(File.dirname(__FILE__), "helpers", "**/*.rb")].each do |f|
  require f
end

Dir[File.join(File.dirname(__FILE__), "helpers", "strategies", "**/*.rb")].each do |f|
  require f
end

RSpec.configure do |config|
  config.extend WithModel
  config.include(Auther::Spec::Helpers)
  config.include(Auther::Spec::Helpers::Mock)
  config.include(Dry::Monads[:list, :result, :validated, :do, :maybe])

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
