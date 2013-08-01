require "page_object_wrapper"
require 'headless'

RSpec.configure do |config|
  $headless = Headless.new
  config.before(:suite){
    PageObjectWrapper.load('./good_pages')
    #$headless.start
  }

  config.after( :suite ){
    #$headless.destroy
  }
end
