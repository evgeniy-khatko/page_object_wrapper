require "page_object_wrapper"

RSpec.configure do |config|
  config.before(:suite){
    Selenium::WebDriver::Firefox.path='/opt/firefox/firefox'
    PageObjectWrapper.load('./good_pages')
  }
end
