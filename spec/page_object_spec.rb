# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Page object" do
  describe "PageObjectWrapper" do
    let(:google_search_page_class){
      class GoogleSearchPage < PageObjectWrapper::Page
        attr_accessor :find_form
        @url="/"
        def initialize visit=false 
          super visit
        end
      end
      GoogleSearchPage
    }

    it "has .start_browser method which puts Watir::Browser.new to Page.accessor by default", :code => 19..20 do
      PageObjectWrapper.stop_browser # stoping browser of (before :suite) hook
      PageObjectWrapper.start_browser
      PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
      PageObjectWrapper.stop_browser
    end

    it "has .stop_browser method which closes browser", :code => 26..27 do
      PageObjectWrapper.start_browser
      PageObjectWrapper.stop_browser
      PageObjectWrapper::Page.accessor.should_not exist
    end

    it "has .restart_browser method which restart current browser", :code => 31..33 do
      PageObjectWrapper.start_browser
      PageObjectWrapper.restart_browser
      PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
      PageObjectWrapper.stop_browser
    end

    it "has .domain= method which reprsents the domain of DUT", :code => 39..41 do
      PageObjectWrapper.start_browser
      PageObjectWrapper.domain = 'www.google.com'
      google_search_page_class.new(true)
      PageObjectWrapper::Page.accessor.title.should eq('Google')
      PageObjectWrapper.stop_browser
    end

    it "has .timeout= method which sets implicit timeout for webdriver (default is 5 sec)" do
      pending "not working yet"
    end
  end

  describe "PageObject class and instance in general", :code => 51..60 do
    let(:page_object){
      class GoogleSearchPage < PageObjectWrapper::Page
        attr_accessor :find_form
        @url="/"
        def initialize visit=false 
          super visit
        end
      end
      GoogleSearchPage
    }

    it "PageObject class has @url class variable which can be treated as Page specific path inside current domain", :code => 63 do
        page_object.url.should eq('/')
    end

    it "init with \'true\' is similar to openning page in browser", :code => 68..69 do
      PageObjectWrapper.start_browser
      google_search_page = page_object.new(true)
      page_object.accessor.title.should eq('Google')
    end

    it "init with \'false\' just returns new instanse, but does not opens browser on that page", :code => 74..75 do
      PageObjectWrapper.restart_browser
      google_search_page = page_object.new(false)
      page_object.accessor.title.should_not eq('Google')
    end
  end

  describe "expected element", :code => 80..103 do
  let(:google_search_with_wrong_expected_element_page_class){
    class NotGoogleSearchPage < PageObjectWrapper::Page
      attr_accessor :find_form
      @url="/"
      expected_element :text_field, :name => 'some element that does not exist on the page' 

      def initialize visit=false 
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

    it "should raise error when trying to init google_search_with_wrong_expected_element_page_class", :code => 106..113 do
      begin
      gsearch_page = google_search_with_wrong_expected_element_page_class.new(true) 
      rescue PageError => e
        e.should be_a(PageError)
        e.message.should =~ /PROBLEM:/
        e.message.should =~ /PAGE:/
        e.message.should =~ /URL:/
      end
    end

    it "should init google_search_with_correct_expected_element_page_class successfully", :code => 117..118 do
      gsearch_page = google_search_with_correct_expected_element_page_class.new(true)
      gsearch_page.should be_a(google_search_with_correct_expected_element_page_class)
    end
  end

  describe "creation of a PageObject method", :code => 123..163 do
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
          @@accessor.span(:id => 'ab_opt_icon').when_present.click 
          @@accessor.a(:id => 'ab_as').when_present.click
          GoogleAdvancedSearchPage.new 
        end
      end

      class GoogleSearchPage < PageObjectWrapper::Page
        attr_accessor :find_form
        @url="/"
        expected_element :text_field, :name => 'q' 
        def initialize visit=false 
          super visit
          @find_form = form(GoogleResultsPage, {:action => '/search'}) 
          @find_form.editable(:text_field, {:name => 'q'}, :seach_what, '@find_form default value', true) 
        end
      end
      {:gsearch_page_class => GoogleSearchPage, :gresults_page => GoogleResultsPage, :gadv_page => GoogleAdvancedSearchPage}
    }

    it "return value should be another PageObject instance", :code => 166..170 do
      gsearch_page = pages_definition[:gsearch_page_class].new(true)
      gsearch_page.find_form.fill_required 
      gresults_page = gsearch_page.find_form.submit(true) 
      gadv_page = gresults_page.open_advanced_search
      gadv_page.should be_a(pages_definition[:gadv_page])
    end
  end
end
