require 'spec_helper'

describe 'page_object.each_xxx' do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      gp = PageObjectWrapper.receive_page(:google_pagination)
      expect{ gp.pagination_each{ |p| puts p.inspect } }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

    context "invalid locator" do
      it "raises PageObjectWrapper::InvalidPagination" do
        gip = PageObjectWrapper.open_page :google_invalid_pagination
        expect{ gip.invalid_pagination_each{ |p| p.inspect }}.to raise_error PageObjectWrapper::InvalidPagination
      end
    end

    context "invalid limit" do
      it "raises PageObjectWrapper::InvalidPagination" do
        gp = PageObjectWrapper.open_page :google_pagination
        expect{ gp.pagination_each( :limit => -1 ){ |p| p.inspect }}.to raise_error PageObjectWrapper::InvalidPagination
      end
    end

    context "correct parameters ( limit = 3 )" do
      it "opens browser on subeach page and yields corresponding page_object" do
        gp = PageObjectWrapper.open_page(:google_pagination)
        counter = 0
        gp.pagination_each( :limit => 3 ){ |subpage| 
          counter += 1
          subpage.should be_a PageObject 
          subpage.validate_current_number?(counter).should be_true
        }
        yp = PageObjectWrapper.open_page(:yandex_pagination)
        counter = 0
        yp.pagination_each( :limit => 3 ){ |subpage| 
          counter += 1
          subpage.should be_a PageObject 
          subpage.validate_current_number?(counter).should be_true
        }
      end
    end
  end
end
