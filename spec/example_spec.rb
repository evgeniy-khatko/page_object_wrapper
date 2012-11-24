require 'spec_helper'

describe "Overall usage" do
  describe "Test Google for long search query" do
    let(:precondition){"Open google.com page"}
    let(:step1){"Enter long search query into the search field"}
    let(:step2){"Press search button"}
    let(:expected_result){"The requested URL /... is too large to process"}

    describe "Defining two page objects: GoogleSearchPage, GoogleErrorPage and performing test" do
      let(:pages_definition){
        class GoogleSearchPage < PageObjectWrapper::Page
          attr_accessor :find_form
          @url="/"
          expected_element :text_field, :name => 'q' 
          def initialize visit=false 
            super visit
            @find_form = form(GoogleErrorPage, {:action => '/search'}) 
            @find_form.editable(:text_field, {:name => 'q'}, :seach_what, '@find_form default value', true) 
          end
        end
        
        class GoogleErrorPage < PageObjectWrapper::Page
          @url="really does not matter, because navigating to this page done through search query submission"
          #expected_element :ins, {:text => "That\’s an error."}
        end
        {:gsearch_page_class => GoogleSearchPage, :gerror_page => GoogleErrorPage}
      }

      it "performing test" do
        puts precondition
        google_page = pages_definition[:gsearch_page_class].new(true)
        puts step1
        long_query = 'q '*1000
        google_page.find_form.fill_only(:seach_what => long_query)
        puts step2
        google_error_page = google_page.find_form.submit(true)
        google_error_page.should have_text(expected_result)
      end
    end
  end
end
