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
element(:bad_required_flad):
	locator nil not a meaningful Hash or String
	required flag "a string" not a true | false
element(""):
	element "" already defined
	label "" not a Symbol
	locator nil not a meaningful Hash or String
	menu {:fresh_food=>[]} not properly defined (must be { :food_type => \'a string\' | true | false })
element(:e):
	element :e already defined
	menu {"a string"=>"another string"} not properly defined (must be { :food_type => \'a string\' | true | false })
element(:e):
	element :e already defined
	locator {} not a meaningful Hash or String
element(:dublicate_tf):
	element :dublicate_tf already defined
	locator nil not a meaningful Hash or String
element(:another_dublicate_tf):
	element :another_dublicate_tf already defined
	label aliases ["not a symbol"] not an Array of Symbols
	locator nil not a meaningful Hash or String
element(:area):
	locator nil not a meaningful Hash or String
element(""):
	element "" already defined
	label "" not a Symbol
	locator nil not a meaningful Hash or String
element(:some_table):
	locator nil not a meaningful Hash or String
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
table(:some_table):
	header [] not a meaningful Array
pagination(""):
	label "" not a Symbol
	locator {} not a meaningful String
	"1" not found in {}
'
      end
    end
  end
end
