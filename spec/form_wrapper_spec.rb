# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "##Form wrapper" do
  describe "#form definition" do
    let(:page_objects){
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
          @find_form = form(GoogleResultsPage, {:action => '/search'}) 
          @find_form.editable(:text_field, {:name => 'q'}, :seach_what, '@find_form default value', true) 
        end
      end
      {:gresults_page_class => GoogleResultsPage, :gadv_page_class => GoogleAdvancedSearchPage}
    }


    it "is defined as #form(TargetPage, how_find_hash)" do
      page_objects[:gadv_page_class].new(true).as_form.class.should eq(Form)
    end

    it "has #editable(:field_type, how_find_hash, :label, default_value, required?) method to set form's fields
      :field_type sets corresponding watir element type
      how_find_hash is used to locate corresponding watir element on the page
      :label is used to reffer to the form field after definition
      default_value is used to populate fields with default test data
      required = true | false and indicates if the field is required
    " do
      gadv_page = page_objects[:gadv_page_class].new(true)
      gadv_page.as_form.with_words.tag_name.should eq('input')
      gadv_page.as_form.with_words.name.should eq('as_q')
      gadv_page.as_form.with_words.should be_a(Watir::TextField)
    end

    it "has #submitter(:field_type, how_find_hash, how_click_mehtod, click_params) method to set form's submitter
      :field_type sets corresponding watir element type
      how_find_hash is used to locate corresponding watir element on the page
      how_click_mehtod is used to tell Waitr the method which should be applied to click the submitter
      click_params set parameters for the how_click_mehtod
    " do
    end
  end
  describe "#form usage" do
    let(:page_objects){
      class GoogleAdvancedSearchPage < PageObjectWrapper::Page
        attr_accessor :as_form
        @url="/advanced_search"
        expected_element :text_field, :name => 'as_q'
        def initialize visit=false
          super visit
          @as_form = form(GoogleSearchPage, {:name => 'f'})
          @as_form.editable(:text_field, {:name => 'as_q'}, :with_words, 'with_words default value', true)
          @as_form.editable(:text_field, {:name => 'as_epq'}, :with_phrase, 'with_phrase default value', true)
          @as_form.editable(:text_field, {:name => 'as_oq'}, :with_any_word, 'with_any_word default value', false)
          @as_form.submitter(:input, {:type => 'submit'})
        end
      end
      class GoogleSearchPage < PageObjectWrapper::Page
        attr_accessor :find_form
        @url="/"
        expected_element :text_field, :name => 'q' # tells Watir that we expect this element which identifies the page in a uniq way
        def initialize visit=false 
          super visit
          @find_form = form(GoogleSearchPage, {:action => '/search'}) 
          @find_form.editable(:text_field, {:name => 'q'}, :search_what, '@find_form default value', true) 
                                  
        end
      end
      {:gsearch_page_class => GoogleSearchPage, :gadv_page_class => GoogleAdvancedSearchPage}
    }
    
    it "has #submit(flag) method which submits form
      if flag = true than TargetPage instance is returned
      if flag = false than CurrentPage instance is returned
      if submitter is defined, than it's used to submit the form, otherwise standart Watir::Form submit is used
    " do
      gadv_page = page_objects[:gadv_page_class].new(true)
      gsearch_page = gadv_page.as_form.submit(true)
      gsearch_page.should be_a(GoogleSearchPage)
      gsearch_page_reloaded = gsearch_page.find_form.submit(false)
      gsearch_page_reloaded.should be_a(GoogleSearchPage)
    end

    its "field's watir elements can be accessed by labels" do
      gsearch_page = page_objects[:gsearch_page_class].new(true)
      gsearch_page.find_form.search_what.should be_a(Watir::TextField)
    end

    its "fields default values set during form definition can be retrieved with #default(:label) method" do
      gsearch_page = page_objects[:gsearch_page_class].new(true)
      gsearch_page.find_form.default(:search_what).should eq('@find_form default value')
    end

    it "has #each method which allows navigating between form fields" do
      gadv_page = page_objects[:gadv_page_class].new(true)
      gadv_page.as_form.each{|form_field|
        form_field.should be_a(Editable)
        form_field.watir_element.should be_a(Watir::TextField)
      }
    end
    
    it "has #each_required method which allows navigating between form required fields (corresponding watir elements)" do
      gadv_page = page_objects[:gadv_page_class].new(true)
      gadv_page.as_form.each_required{|form_field|
        form_field.should be_a(Editable)
        form_field.watir_element.should be_a(Watir::TextField)
        form_field.should be_required
      }
    end

    it "has #fill_only(:label => value) method which populated form's :label field with \'value\'
      method returns form object
    " do
      gadv_page = page_objects[:gadv_page_class].new(true)
      form = gadv_page.as_form.fill_only(:with_words => 'some value')
      gadv_page.as_form.with_words.value.should eq('some value')
      form.should be_a(Form)
    end

    it "has #fill_all(:except => labels_array | label) method which populated all form's fields with default values
      if except_hash is not nil than provided fields are not populated
      method returns form object
    " do
      gadv_page = page_objects[:gadv_page_class].new(true)
      form = gadv_page.as_form.fill_all
      gadv_page.as_form.each{|field|
        field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
      }
      gadv_page = page_objects[:gadv_page_class].new(true)
      gadv_page.as_form.fill_all(:except => :with_words)
      gadv_page.as_form.each{|field|
        if field.label==:with_words
          field.watir_element.value.should eq ''
        else
          field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
        end
      }
      form.should be_a(Form)
    end

    it "has #fill_required(:except => labels_array | label) method which populated all required form's fields with default values
      if except_hash is not nil than provided fields are not populated
      method returns form object
    " do
      gadv_page = page_objects[:gadv_page_class].new(true)
      form = gadv_page.as_form.fill_required
      gadv_page.as_form.each_required{|field|
        field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
      }
      gadv_page = page_objects[:gadv_page_class].new(true)
      gadv_page.as_form.fill_all(:except => :with_words)
      gadv_page.as_form.each_required{|field|
        if field.label==:with_words
          field.watir_element.value.should eq ''
        else
          field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
        end
      }
      form.should be_a(Form)
    end
  end
end
