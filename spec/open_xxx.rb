require 'spec_helper'

describe 'page_object.open_xxx' do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      gp = PageObjectWrapper.receive_page(:google_pagination)
      expect{ gp.open_pagination 1 }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "invalid locator" do
    it "raises PageObjectWrapper::InvalidPagination" do
    end
  end

  context "inappropriate number provided" do
    it "raises PageObjectWrapper::OutOfBoundsSubpage" do
    end
  end

  context "correct parameters" do
    it "opens browser on provided subpage returns corresponding page_object" do
    end
  end
end

