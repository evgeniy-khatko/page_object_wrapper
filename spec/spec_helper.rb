require "page_object_wrapper"

RSpec.configure do |config|
  config.before(:suite){
    PageObjectWrapper.load('./good_pages')
  }
end
