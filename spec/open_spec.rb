require 'spec_helper'

describe "PageObjectWrapper.open_page" do
  context "browser is closed" do
    it "raises Errno::ECONNREFUSED (I don't understand why here it behaves like this)" do
      expect{ PageObjectWrapper.open_page(:google_page) }.to raise_error(Errno::ECONNREFUSED)
    end
  end

  context "browser is opened" do
    
    before(:all){ 
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b 
    }

    after(:all){ PageObjectWrapper.browser.quit }

    it "raises errors" do        
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
end
