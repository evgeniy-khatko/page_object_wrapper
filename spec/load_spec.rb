require 'spec_helper'

describe "PageObjectWrapper.load" do
  it "accepts path to the \'pages\' folder" do
    expect{ PageObjectWrapper.load('unknown/dir')}.to raise_error(PageObjectWrapper::Load)
  end

  describe "page load" do
    it "raises PageObjectWrapper::Load error with all errors described" do
      begin
        PageObjectWrapper.load(File.dirname(__FILE__)+'/../bad_pages')
      rescue Exception => e
        #puts '=============='
        #puts e.message
        #puts '=============='
        e.should be_a(PageObjectWrapper::Load)
        e.message.should == 'page_object("some_page_with_lost_of_errors"):
	label "some_page_with_lost_of_errors" not a Symbol
	locator "" not a meaningful String
elements_set("some elements_set label"):
	label "some elements_set label" not a Symbol
	element(""):
		label "" not a Symbol
		locator nil not a meaningful Hash or String
		menu {:fresh_food=>[], :missing_food=>"default missing food"} not properly defined (must be {:food_type => \'a string\'})
	element(:e):
		element :e already defined
		menu {:fresh_food=>"default fresh food", :missing_food=>"default missing food", "a string"=>"another string"} not properly defined (must be {:food_type => \'a string\'})
	element(:e):
		element :e already defined
		locator {} not a meaningful Hash or String
action(""):
	label "" not a Symbol
	next_page "a string" not a Symbol
	next_page "a string" unknown page_object
alias(""):
	label "" not a Symbol
	next_page "a string" not a Symbol
	next_page "a string" unknown page_object
	action "unknown action" not known Action
validator(""):
	label "" not a Symbol
table(""):
	label "" not a Symbol
	locator nil not a meaningful Hash
table(:some_table):
	locator nil not a meaningful Hash
	header [] not a meaningful Array
pagination(""):
	label "" not a Symbol
	locator "pagination locator" not a meaningful Hash
'
      end
    end
  end
end
