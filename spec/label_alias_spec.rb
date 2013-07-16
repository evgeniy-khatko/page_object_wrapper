require 'spec_helper'

describe "label_aliases" do
  before(:all){ 
    @b = Watir::Browser.new :chrome
    PageObjectWrapper.use_browser @b 
  }

  after(:all){ PageObjectWrapper.browser.quit }

  let(:tp){ PageObjectWrapper.open_page :page_name_alias }
  
  it "opens correct page by alias" do
    tp = PageObjectWrapper.open_page :page_name_alias
    tp2 = PageObjectWrapper.open_page :another_page_name_alias
    tp.should eq tp2
    PageObjectWrapper.current_page?(:page_with_aliases).should eq true
    PageObjectWrapper.current_page?(:page_name_alias).should eq true
    PageObjectWrapper.current_page?(:another_page_name_alias).should eq true
  end

  it "works with text_field" do
    tp.feed_text_field_alias 'text'
    PageObjectWrapper.current_result.should be_a Watir::TextField
    PageObjectWrapper.current_result?(:value, 'text').should eq true
  end

  it "works with returned values" do
    tf = tp.text_field_alias
    tf.should be_a Watir::TextField
  end
  
  it "works with elements_set" do
    tp.feed_eset_alias :loud
    expected = ["ta food", "1", "on", "one"]
    PageObjectWrapper.current_result.should be_a Array
    PageObjectWrapper.current_result?("collect(&:value)", expected).should eq true
  end

  it "works with action" do
    tp.fire_action_alias
    PageObjectWrapper.current_result.should be_a PageObjectWrapper::PageObject
    PageObjectWrapper.current_result?(:label_value, :test_page_with_table).should eq true
  end
    
  it "works with table alias" do
    tp.select_from_table_alias(:country, :row => 2)
    PageObjectWrapper.current_result.should be_a Watir::TableCell
    PageObjectWrapper.current_result?(:text, 'Denmark').should eq true
  end
end

