require 'spec_helper'

describe 'page_object.each_xxx' do
 # context "browser is closed" do
 #   it "raises PageObjectWrapper::BrowserNotFound" do
 #     gp = PageObjectWrapper.receive_page(:google_pagination)
 #     expect{ gp.pagination_each{ |p| puts p.inspect } }.to raise_error(PageObjectWrapper::BrowserNotFound)
 #   end
 # end

  context "browser is openen" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

   # context "invalid locator" do
   #   it "raises PageObjectWrapper::InvalidPagination" do
   #     gip = PageObjectWrapper.open_page :google_invalid_pagination
   #     expect{ gip.invalid_pagination_each{ |p| p.inspect }}.to raise_error PageObjectWrapper::InvalidPagination
   #   end
   # end

    context "correct parameters" do
      it "opens browser on subeach page and yields corresponding page_object" do
        gp = PageObjectWrapper.open_page(:google_pagination)
        gp.pagination_each{ |subpage| subpage.should be_a PageObject }
        yp = PageObjectWrapper.open_page(:yandex_pagination)
        yp.pagination_each{ |subpage| subpage.should be_a PageObject }
      end
    end
  end
end
