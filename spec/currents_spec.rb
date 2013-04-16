require 'spec_helper'

describe "returned values" do
  before(:all){ 
    @b = Watir::Browser.new
    PageObjectWrapper.use_browser @b 
  }

  after(:all){ PageObjectWrapper.browser.quit }
  
  it "returns corresponding values" do
    tp = PageObjectWrapper.open_page :some_test_page
    PageObjectWrapper.current_page.should be_a PageObjectWrapper::PageObject
    PageObjectWrapper.current_page?(:some_test_page).should eq true

    tp.feed_tf 'text'
    PageObjectWrapper.current_result.should be_a Watir::TextField
    PageObjectWrapper.current_result?(:value, 'text').should eq true

    tp.feed_test_elements :loud
    expected = ["bar", "tf food", "ta food", "1", "2", "on", "on", "one", "one"]
    PageObjectWrapper.current_result.should be_a Array
    PageObjectWrapper.current_result?("collect(&:value)", expected).should eq true

    tp = tp.fire_press_cool_button
    PageObjectWrapper.current_result.should be_a PageObjectWrapper::PageObject
    PageObjectWrapper.current_result?(:label_value, :test_page_with_table).should eq true
    
    tp.select_from_test_table(:column_1, :row => 0)
    PageObjectWrapper.current_result.should be_a Watir::TableCell
    PageObjectWrapper.current_result?(:text, '42').should eq true

    tp.select_row_from_test_table(:number => 0)
    PageObjectWrapper.current_result.should be_a Hash
    PageObjectWrapper.current_result?("fetch(:column_1).text", '42').should eq true
  end
end
