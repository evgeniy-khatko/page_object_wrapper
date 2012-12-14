require 'spec_helper'

describe "PageObjectWrapper.open_page" do
  let(:define_page_object){
    PageObjectWrapper.define_page(:google_page) do
      locator 'google.com'
      uniq_element :id => 'gbqfq'
    end
  }
  let(:define_wrong_page_object){
    PageObjectWrapper.define_page(:wrong_google_page) do
      locator 'google.com'
      uniq_element :id => 'foobar'
    end
  }

  it "accepts one argument - :label of the page to open" do
    begin
      PageObjectWrapper.open_page(:first_arg, :second_arg)
    rescue Exception => e
      e.message.should eq('wrong number of arguments (2 for 1)')
    end
  end

  it "navigates current browser to the specified PageObject instance locator (url)" do
    PageObjectWrapper.start_browser
    define_page_object
    gp = PageObjectWrapper.open_page(:google_page)
    gp.should be_a(PageObject)
    PageObjectWrapper.stop_browser
  end

  it "raises PageObjectWrapper::UnmappedPageObject if a page object with provided label has not been found" do
    begin    
      unknown_page = PageObjectWrapper.open_page(:unknown_page)
    rescue Exception => e
      e.should be_a(PageObjectWrapper::UnknownPageObject)
      e.message.should eq("unknown_page")
    end
  end

  it "raises PageObjectWrapper::UnmappedPageObject if the uniq_element has not been found" do
    PageObjectWrapper.start_browser
    define_wrong_page_object
    begin
      gp = PageObjectWrapper.open_page(:wrong_google_page)
    rescue Exception => e
      e.should be_a(PageObjectWrapper::UnmappedPageObject)
      e.message.should eq('wrong_google_page')
    end
    PageObjectWrapper.stop_browser
  end

  it "returns opened PageObject instance" do
    p = define_wrong_page_object
    p.should be_a(PageObject)    
  end
end
