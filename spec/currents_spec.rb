require 'spec_helper'

describe "returned values" do
  before(:all){ 
    @b = Watir::Browser.new
    PageObjectWrapper.use_browser @b 
  }

  after(:all){ PageObjectWrapper.browser.quit }
  
  it "returns corresponding values" do
    tp = PageObjectWrapper.open_page :some_test_page
    res = PageObjectWrapper.current_page
    res.should be_a PageObjectWrapper::PageObject
    res.label_value.should eq :some_test_page

    tp.feed_tf 'text'
    res = PageObjectWrapper.current_action_result
    res.should be_a Watir::TextField
    res.value.should eq 'text'

    tp.feed_test_elements :loud
    res = PageObjectWrapper.current_action_result
    res.should be_a Array
    res.collect(&:value).should eq ["bar", "tf food", "ta food", "1", "2", "on", "on", "one", "one"]

    tp = tp.fire_press_cool_button
    res = PageObjectWrapper.current_action_result
    res.should be_a PageObjectWrapper::PageObject
    res.label_value.should eq :test_page_with_table
    
    tp.select_from_test_table(:column_1, :row => 0)
    res = PageObjectWrapper.current_table_cell
    res.should be_a Watir::TableCell
    res.text.should eq '42'

    tp.select_row_from_test_table(:number => 0)
    res = PageObjectWrapper.current_table_row
    res.should be_a Hash
    res[:column_1].text.should eq '42'
  end
end
