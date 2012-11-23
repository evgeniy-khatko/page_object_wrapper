# -*- encoding : utf-8 -*-
require "rspec"
require 'page_object_wrapper'

RSpec.configure do |config|
config.before(:suite) {
	PageObjectWrapper.start_browser
	PageObjectWrapper.domain = 'http://google.com'
}

config.after(:suite) {    
	PageObjectWrapper.stop_browser
}
end

