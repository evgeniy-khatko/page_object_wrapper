# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "expected_element" do
let(:google_search_with_wrong_expected_element_page_class){
	class NotGoogleSearchPage < PageObjectWrapper::Page
		attr_accessor :find_form
		@url="/"
		expected_element :text_field, :name => 'some element that does not exist on the page' # tells Watir that we expect this element which identifies the page in a uniq way

		def initialize visit=false # passes true to force Watir navigating to this page, otherwise just a Page instance will be returned
			super visit
		end
	end
	NotGoogleSearchPage
}
let(:google_search_with_correct_expected_element_page_class){
	class GoogleSearchPage < PageObjectWrapper::Page
		attr_accessor :find_form
		@url="/"
		expected_element :text_field, :name => 'q'

		def initialize visit=false 
			super visit
		end
	end
	GoogleSearchPage
}

	it "should raise error when trying to init google_search_with_wrong_expected_element_page_class" do
		begin
		gsearch_page = google_search_with_wrong_expected_element_page_class.new(true) 
		rescue PageError => e
			e.should be_a(PageError)
			e.message.should =~ /PROBLEM:/
			e.message.should =~ /PAGE:/
			e.message.should =~ /URL:/
		end
	end

	it "should init google_search_with_correct_expected_element_page_class successfully" do
		gsearch_page = google_search_with_correct_expected_element_page_class.new(true)
		gsearch_page.should be_a(google_search_with_correct_expected_element_page_class)
	end
end
