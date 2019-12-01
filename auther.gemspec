# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "auther"
  s.version = "0.0.0"
  s.date = "2019-11-04"
  s.summary = "Token-based Authentication for Rails apps"
  s.description = "Token-based Authentication for Rails apps"
  s.authors = ["Karim Almur"]
  s.email = "karimit.g@gmail.com"
  s.homepage = "https://rubygems.org/gems/auther"
  s.license = "MIT"

  s.add_dependency "bcrypt", ">= 3.1.11"
  s.add_dependency "dry-monads", "~> 1.3", ">= 1.3.1"
  s.add_dependency "jwt", "~> 2.2", ">= 2.2.1"
  s.add_dependency "rack", "~> 2.0", ">= 2.0.7"

  s.add_development_dependency "activerecord", "~> 5.0"
  s.add_development_dependency "simplecov", "~> 0.17.1"
  s.add_development_dependency "sqlite3", "~> 1.4", ">= 1.4.1"
  s.add_development_dependency "with_model", "~> 2.1", ">= 2.1.2"

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
end
