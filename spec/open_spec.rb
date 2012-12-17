require 'spec_helper'

describe "PageObjectWrapper.open_page" do
  let(:define_page_object){
    PageObjectWrapper.define_page(:google_page) do
      locator 'google.com'
      uniq_input :id => 'gbqfq'
    end
  }
  let(:define_wrong_page_object){
    PageObjectWrapper.define_page(:wrong_google_page) do
      locator 'google.com'
      uniq_element :id => 'foobar'
    end
  }
  let(:define_page_object_with_local_path){
    PageObjectWrapper.define_page(:google_as_page) do
      locator '/advanced_search'
      uniq_text_field :name => 'as_q' 
    end
  }
  
  before(:all){ 
    @b = Watir::Browser.new
    PageObjectWrapper.use_browser @b 
  }

  before(:each){
    define_page_object
    define_wrong_page_object
    define_page_object_with_local_path
  }

  after(:all){ PageObjectWrapper.browser.close }

  it "raises following errors" do        
    expect{ PageObjectWrapper.open_page(:first_arg, :second_arg) }.to raise_error(ArgumentError)
    expect{ PageObjectWrapper.open_page(:unknown_page) }.to raise_error(PageObjectWrapper::UnknownPageObject)
    expect{ PageObjectWrapper.open_page(:wrong_google_page) }.to raise_error(PageObjectWrapper::UnmappedPageObject)
  end

  it "returns opened PageObject instance" do
    p = PageObjectWrapper.open_page(:google_page)
    p.should be_an_instance_of(PageObject)
    p.label_value.should eq(:google_page)
  end

  context "domain is not specified" do
    it "opens browser on the page.locator" do
      gp = PageObjectWrapper.open_page(:google_page)
      @b.url.should =~/www\.google/
    end
  end

  context "domain is specified" do
    it "opens browser on domain+page.locator" do
      PageObjectWrapper.domain = 'google.com'
      PageObjectWrapper.open_page(:google_as_page)        
      @b.url.should =~/\/advanced_search/
    end
  end
end
