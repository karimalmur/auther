# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "auther"
  s.version     = "0.0.0"
  s.date        = "2019-11-04"
  s.summary     = "Token-based Authentication for Rails apps"
  s.description = "Token-based Authentication for Rails apps"
  s.authors     = ["Karim Almur"]
  s.email       = "karimit.g@gmail.com"
  s.files       = ["lib/auther.rb"]
  s.homepage    = "https://rubygems.org/gems/auther"
  s.license     = "MIT"

  s.add_dependency "bcrypt", ">= 3.1.11"
  s.add_dependency "jwt", "~> 2.2", ">= 2.2.1"
  s.add_dependency "rack", "~> 2.0", ">= 2.0.7"
end
