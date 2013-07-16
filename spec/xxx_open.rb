require 'spec_helper'

describe 'page_object.open_xxx' do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      gp = PageObjectWrapper.receive_page(:google_pagination)
      expect{ gp.pagination_open 1 }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new :chrome
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

    context "invalid locator" do
      it "raises PageObjectWrapper::InvalidPagination" do
        gip = PageObjectWrapper.open_page :google_invalid_pagination
        expect{ gip.invalid_pagination_open(1) }.to raise_error PageObjectWrapper::InvalidPagination
      end
    end

    context "inappropriate number provided" do
      it "raises Watir::Wait::TimeoutError" do
        gp = PageObjectWrapper.open_page(:google_pagination)
        expect{ gp.pagination_open(0)}.to raise_error Watir::Wait::TimeoutError
      end
    end

    context "correct parameters" do
      it "opens browser on provided subpage returns corresponding page_object" do
        n = 10
        yp = PageObjectWrapper.open_page(:yandex_pagination)
        yp.pagination_open(n).should be_a PageObjectWrapper::PageObject
        yp.validate_current_number?(n).should be_true
        gp = PageObjectWrapper.open_page(:google_pagination)
        gp.pagination_open(n).should be_a PageObjectWrapper::PageObject
        gp.validate_current_number?(n).should be_true
      end
    end
  end
end
