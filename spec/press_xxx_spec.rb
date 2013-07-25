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
    before(:each){ @tp = PageObjectWrapper.open_page(:some_test_page) }
    after(:all){ PageObjectWrapper.browser.quit }
    let(:tp){ PageObjectWrapper.current_page }

    context "xxx not found among current_page elements" do
      it "raises NoMethodError" do
        expect{ tp.press_nonexistent_element }.to raise_error(NoMethodError)
      end
    end

    context "element does not respond to user action" do
      it "raises InvalidElement error" do
        expect{ tp.press_invalid_press_action_button }.to raise_error(PageObjectWrapper::InvalidElement)
      end
    end

    context "element does not present" do
      it "raises InvalidElement error" do
        expect{ tp.press_invalid_button }.to raise_error(Watir::Wait::TimeoutError)
      end
    end

    context "basic usage" do

      it "returns pressed watir element" do
        tp.press_cool_button.should be_a Watir::Button
      end

      it "really presses the element" do
        tp.press_standalone_cool_button_with_default_press_action
        PageObjectWrapper.current_page?(:test_page_with_table).should be_true
      end

      it "presses with user defined action" do
        tp.press_standalone_cool_button
        PageObjectWrapper.current_page?(:test_page_with_table).should be_true
      end

      it "presses element inside an elements_set" do
        tp.press_cool_button
        PageObjectWrapper.current_page?(:test_page_with_table).should be_true
      end
    end
  end
end

