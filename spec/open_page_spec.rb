require 'spec_helper'

describe "PageObjectWrapper.open_page" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      expect{ PageObjectWrapper.open_page(:google_page) }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "browser is opened" do
    
    before(:all){ 
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b 
    }

    after(:all){ PageObjectWrapper.browser.quit }

    it "raises errors" do        
      expect{ PageObjectWrapper.open_page(:unknown_page) }.to raise_error(PageObjectWrapper::UnknownPageObject)
      expect{ PageObjectWrapper.open_page(:wrong_google_page) }.to raise_error(PageObjectWrapper::UnmappedPageObject)
    end

    context "no optional arguments" do
      it "returns opened PageObjectWrapper::PageObject instance" do
        p = PageObjectWrapper.open_page(:google_page)
        p.should be_an_instance_of(PageObjectWrapper::PageObject)
        p.label_value.should eq(:google_page)
      end
    end

    context "with optional arguments" do
      context "optional hash key not Symbol" do
        it "raises ArgumentError" do
          expect{ PageObjectWrapper.open_page(:dynamic_url_page, 'a string' => 'a string') }.to raise_error ArgumentError, '"a string" not Symbol'
        end
      end
      context "optional hash value not meaningful String" do
        it "raises ArgumentError" do
          expect{ PageObjectWrapper.open_page(:dynamic_url_page, :param => '') }.to raise_error ArgumentError, '"" not meaningful String'
        end
      end
      context "one optional parameter not known" do
        it "raises PageObjectWrapper::DynamicUrl" do
          expect{ PageObjectWrapper.open_page(:dynamic_url_page, :domain => 'google.com', :unknown_url_parameter => '123') }.to raise_error PageObjectWrapper::DynamicUrl, ":unknown_url_parameter not known parameter"
        end
      end
      context "at least one dynamic parameter specified" do
        it "opens page with all parameters replaced with specified" do
          begin
            PageObjectWrapper.open_page(:dynamic_url_page, :domain => 'google.com')
          rescue PageObjectWrapper::UnmappedPageObject
            PageObjectWrapper::PageObject.browser.url.should =~ /google.\w+\/:path/
          end
        end
      end
      context "all dynamic parameters specified" do
        it "opens page with all parameters replaced with specified" do
          PageObjectWrapper.open_page(:dynamic_url_page, :domain => 'google.com', :path => 'advanced_search')
          PageObjectWrapper::PageObject.browser.url.should =~ /google.\w+\/advanced_search/
        end
      end
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
