require 'spec_helper'
require 'shared_examples'

describe "page_object.fire_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.fire_press_cool_button }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end
  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

    it "executes fire_block in Watir::Browser context" do
      tp = PageObjectWrapper.open_page(:some_test_page)
      tp.fire_fill_textarea
      tp.validate_textarea_value('Default data').should be(true)
    end

    context "xxx not found among current_page actions" do
      it "raises NoMethodError" do
        tp = PageObjectWrapper.current_page
        expect{tp.fire_nonexistent_action}.to raise_error(NoMethodError)
      end
    end

    it "can be invoked with parameters" do
      tp = PageObjectWrapper.current_page
      tp.fire_fill_textarea('User defined data')
      tp.validate_textarea_value('User defined data').should be(true)
    end

    context "xxx is alias" do
      it "executes corresponding action" do
        tp = PageObjectWrapper.open_page(:some_test_page)
        tp.fire_fill_textarea_alias
        tp.validate_textarea_value('Default data').should be(true)
      end
    end

    it "returns next_page" do
      tp = PageObjectWrapper.current_page
      np = tp.fire_press_cool_button
      np.should be_a(PageObject)
      np.label_value.should eq(:test_page_with_table)
    end

  end
end
