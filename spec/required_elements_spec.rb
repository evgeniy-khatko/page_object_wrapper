require 'spec_helper'

describe "page_object required elements" do
  describe "required elements are checked during .open_page" do
    
    context "browser is closed" do
      it "raises PageObjectWrapper::BrowserNotFound" do
        tp = PageObjectWrapper.receive_page(:some_test_page)
        expect{ PageObjectWrapper.open_page :some_test_page }.to raise_error(PageObjectWrapper::BrowserNotFound)
      end
    end

    context "browser is opened" do
      before(:all){
        @b = Watir::Browser.new
        PageObjectWrapper.use_browser @b
      }

      after(:all){ PageObjectWrapper.browser.quit }

      context "one of required elements not found" do
        it "raises UnmappedPageObject error" do
          expect{ PageObjectWrapper.open_page :required_missing }.to raise_error(PageObjectWrapper::UnmappedPageObject)
        end
      end

      context "one of uniq elements not found" do
        it "raises UnmappedPageObject error" do
          expect{ PageObjectWrapper.open_page :uniq_missing }.to raise_error(PageObjectWrapper::UnmappedPageObject)
        end
      end
    end
  end

  describe "required elements are checked during .current_page?" do
    context "browser is closed" do
      it "raises PageObjectWrapper::BrowserNotFound" do
        tp = PageObjectWrapper.receive_page(:some_test_page)
        expect{ PageObjectWrapper.current_page? :some_test_page }.to raise_error(Watir::Exception::Error)
      end
    end

    context "browser is opened" do
      before(:all){
        @b = Watir::Browser.new
        PageObjectWrapper.use_browser @b
      }

      after(:all){ PageObjectWrapper.browser.quit }
      before(:all){ PageObjectWrapper.open_page :some_test_page }

      context "one of required elements not found" do
        it "raises UnmappedPageObject error" do
          expect{ PageObjectWrapper.current_page? :required_missing }.to raise_error(PageObjectWrapper::UnmappedPageObject)
        end
      end

      context "one of uniq elements not found" do
        it "raises UnmappedPageObject error" do
          expect{ PageObjectWrapper.current_page? :uniq_missing }.to raise_error(PageObjectWrapper::UnmappedPageObject)
        end
      end
    end
  end
end
