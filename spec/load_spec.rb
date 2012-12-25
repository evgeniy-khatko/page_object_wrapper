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
        #puts e.message
        e.should be_a(PageObjectWrapper::Load)
        e.message.should == 'page_object("some_page_with_lost_of_errors"):
	label "some_page_with_lost_of_errors" not a Symbol
	locator "" not a meaningful String
elements_set("some elements_set label"):
	label "some elements_set label" not a Symbol
	element(""):
		label "" not a Symbol
		locator nil not a meaningful Hash
	element(:e):
		element :e already defined
		locator ":e element locator" not a meaningful Hash
	element(:e):
		element :e already defined
		locator {} not a meaningful Hash
action(""):
	label "" not a Symbol
	next_page nil not a Symbol
	next_page nil unknown page_object
alias(""):
	label "" not a Symbol
	next_page nil not a Symbol
	next_page nil unknown page_object
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
