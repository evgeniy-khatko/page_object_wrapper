# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'page_object_wrapper/version'

Gem::Specification.new do |gem|
  gem.name          = "page_object_wrapper"
  gem.version       = PageObjectWrapper::VERSION
  gem.authors       = ["Evgeniy Khatko"]
  gem.email         = ["evgeniy.khatko@gmail.com"]
  gem.description   = %q{Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.}
  gem.summary       = %q{Wraps watir-webdriver with convenient testing interface.}
  gem.homepage      = "https://github.com/evgeniy-khatko/page_object_wrapper"
	gem.add_dependency "watir-webdriver"
	gem.add_dependency "activesupport"
	gem.add_development_dependency "rspec", ">= 2.0.0"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib","lib/page_object_wrapper"]
end
