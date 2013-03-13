require 'spec_helper'

describe "page_object.press_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.press_standalone_cool_button }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

    context "xxx not found among current_page elements" do
      it "raises NoMethodError" do
        tp = PageObjectWrapper.current_page
        expect{ tp.press_nonexistent_element }.to raise_error(NoMethodError)
      end
    end

    context "basic usage" do
      before(:all){ PageObjectWrapper.open_page :some_test_page }
      let(:tp){ PageObjectWrapper.current_page }

      it "returns pressed watir element" do
        tp.press_main_page_link.should be_a Watir::Anchor
      end

      it "really presses the element" do
        tp.press_standalone_cool_button
        PageObjectWrapper.current_page(:test_page_with_table).should be_true
      end
    end
  end
end

