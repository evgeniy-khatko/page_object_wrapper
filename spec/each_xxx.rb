require 'spec_helper'

describe 'page_object.each_xxx' do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      gp = PageObjectWrapper.receive_page(:google_pagination)
      expect{ gp.each_pagination{ |p| puts p } }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "invalid locator" do
    it "raises PageObjectWrapper::InvalidPagination" do
    end
  end

  context "correct parameters" do
    it "opens browser on subeach page and yields corresponding page_object" do
    end
  end
end
