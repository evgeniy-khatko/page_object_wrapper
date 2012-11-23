# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "creation of a PageObject method" do
	let(:pages_definition){
		class GoogleAdvancedSearchPage < PageObjectWrapper::Page
			attr_accessor :as_form
			@url="/advanced_search"
			expected_element :text_field, :name => 'as_q'
			def initialize visit=false
				super visit
				@as_form = form(GoogleResultsPage, {:name => 'f'})
				@as_form.editable(:text_field, {:name => 'as_q'}, :with_words, 'with_words default value', true)
				@as_form.editable(:text_field, {:name => 'as_epq'}, :with_phrase, 'with_phrase default value', true)
				@as_form.editable(:text_field, {:name => 'as_oq'}, :with_any_word, 'with_any_word default value', false)
				@as_form.submitter(:input, {:type => 'submit'})
			end
		end

		class GoogleResultsPage < PageObjectWrapper::Page
			@url="/"
			expected_element :button, :name => 'btnG'
			def initialize visit=false 
				super visit
			end

			def open_advanced_search
				@@accessor.span(:id => 'ab_opt_icon').when_present.click # @@accessor is the instance of a Watir browser
				@@accessor.a(:id => 'ab_as').when_present.click
				GoogleAdvancedSearchPage.new # each method of a SomePageObject should return the 'next' PageObject instance
			end
		end

		class GoogleSearchPage < PageObjectWrapper::Page
			attr_accessor :find_form
			@url="/"
			expected_element :text_field, :name => 'q' # tells Watir that we expect this element which identifies the page in a uniq way
			def initialize visit=false 
				super visit
				@find_form = form(GoogleResultsPage, {:action => '/search'}) 
				@find_form.editable(:text_field, {:name => 'q'}, :seach_what, '@find_form default value', true) 
			end
		end
		{:gsearch_page_class => GoogleSearchPage, :gresults_page => GoogleResultsPage, :gadv_page => GoogleAdvancedSearchPage}
	}

	its "return value should be Another PageObject instance" do
		gsearch_page = pages_definition[:gsearch_page_class].new(true)
		gsearch_page.find_form.fill_required # calling without arguments causes required form fields to be populated with default values
		gresults_page = gsearch_page.find_form.submit(true) # => GoogleResultsPage.new(false)
		gadv_page = gresults_page.open_advanced_search
		gadv_page.should be_a(pages_definition[:gadv_page])
	end
end


