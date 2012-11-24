# PageObjectWrapper

Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.

## Installation

Install Firefox on your system

Add this line to your application's Gemfile:

    gem 'page_object_wrapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install page_object_wrapper

## Usage

####please look into specs for more detailed usage examples

#Page object

##PageObjectWrapper

###has .start_browser method which puts Watir::Browser.new to Page.accessor by default
          PageObjectWrapper.start_browser
          PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
###has .stop_browser method which closes browser
          PageObjectWrapper.stop_browser
          PageObjectWrapper::Page.accessor.should_not exist
###has .restart_browser method which restart current browser
          PageObjectWrapper.start_browser
          PageObjectWrapper.restart_browser
          PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
###has .domain= method which reprsents the domain of DUT
          PageObjectWrapper.domain = 'www.google.com'
          google_search_page_class.new(true)
          PageObjectWrapper::Page.accessor.title.should eq('Google')
###has .timeout= method which sets implicit timeout for webdriver (default is 5 sec)
    not working yet
##PageObject class and instance in general
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
###PageObject class has @url class variable which can be treated as Page specific path inside current domain
            page_object.url.should eq('/')
###init with 'true' is similar to openning page in browser
          google_search_page = page_object.new(true)
          page_object.accessor.title.should eq('Google')
###init with 'false' just returns new instanse, but does not opens browser on that page
          google_search_page = page_object.new(false)
          page_object.accessor.title.should_not eq('Google')
##expected element
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
###should raise error when trying to init google_search_with_wrong_expected_element_page_class
          begin
          gsearch_page = google_search_with_wrong_expected_element_page_class.new(true) 
          rescue PageError => e
            e.should be_a(PageError)
            e.message.should =~ /PROBLEM:/
            e.message.should =~ /PAGE:/
            e.message.should =~ /URL:/
          end
###should init google_search_with_correct_expected_element_page_class successfully
          gsearch_page = google_search_with_correct_expected_element_page_class.new(true)
          gsearch_page.should be_a(google_search_with_correct_expected_element_page_class)
##creation of a PageObject method
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
###return value should be another PageObject instance
          gsearch_page = pages_definition[:gsearch_page_class].new(true)
          gsearch_page.find_form.fill_required 
          gresults_page = gsearch_page.find_form.submit(true) 
          gadv_page = gresults_page.open_advanced_search
          gadv_page.should be_a(pages_definition[:gadv_page])

#Form wrapper

##form definition
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
###is defined as #form(TargetPage, how_find_hash)
              @as_form = form(GoogleResultsPage, {:name => 'f'})
              @find_form = form(GoogleResultsPage, {:action => '/search'}) 
###has #editable(:field_type, how_find_hash, :label, default_value, required?) method to set form's fields
###      :field_type sets corresponding watir element type
###      how_find_hash is used to locate corresponding watir element on the page
###      :label is used to reffer to the form field after definition
###      default_value is used to populate fields with default test data
###      required = true | false and indicates if the field is required
###    
              @as_form.editable(:text_field, {:name => 'as_q'}, :with_words, 'with_words default value', true)
              @as_form.editable(:text_field, {:name => 'as_epq'}, :with_phrase, 'with_phrase default value', true)
              @as_form.editable(:text_field, {:name => 'as_oq'}, :with_any_word, 'with_any_word default value', false)
###has #submitter(:field_type, how_find_hash, how_click_mehtod, click_params) method to set form's submitter
###      :field_type sets corresponding watir element type
###      how_find_hash is used to locate corresponding watir element on the page
###      how_click_mehtod is used to tell Waitr the method which should be applied to click the submitter
###      click_params set parameters for the how_click_mehtod
###    
              @as_form.submitter(:input, {:type => 'submit'})
##form usage
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
###has #submit(flag) method which submits form
###      if flag = true than TargetPage instance is returned
###      if flag = false than CurrentPage instance is returned
###      if submitter is defined, than it's used to submit the form, otherwise standart Watir::Form submit is used
###    
          gadv_page = page_objects[:gadv_page_class].new(true)
          gsearch_page = gadv_page.as_form.submit(true)
          gsearch_page.should be_a(GoogleSearchPage)
          gsearch_page_reloaded = gsearch_page.find_form.submit(false)
          gsearch_page_reloaded.should be_a(GoogleSearchPage)
###field's watir elements can be accessed by labels
          gsearch_page = page_objects[:gsearch_page_class].new(true)
          gsearch_page.find_form.search_what.should be_a(Watir::TextField)
###fields default values set during form definition can be retrieved with #default(:label) method
          gsearch_page = page_objects[:gsearch_page_class].new(true)
          gsearch_page.find_form.default(:search_what).should eq('@find_form default value')
###has #each method which allows navigating between form fields
          gadv_page.as_form.each{|form_field|
            form_field.should be_a(Editable)
            form_field.watir_element.should be_a(Watir::TextField)
###has #each_required method which allows navigating between form required fields
          gadv_page.as_form.each_required{|form_field|
            form_field.should be_a(Editable)
            form_field.watir_element.should be_a(Watir::TextField)
            form_field.should be_required
          }
###has #fill_only(:label => value) method which populated form's :label field with 'value'
###      method returns form object
###    
          form = gadv_page.as_form.fill_only(:with_words => 'some value')
          gadv_page.as_form.with_words.value.should eq('some value')
###has #fill_all(:except => labels_array | label) method which populated all form's fields with default values
###      if except_hash is not nil than provided fields are not populated
###      method returns form object
###    
          form = gadv_page.as_form.fill_all
          gadv_page.as_form.each{|field|
            field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
          }
###has #fill_required(:except => labels_array | label) method which populated all required form's fields with default values
###      if except_hash is not nil than provided fields are not populated
###      method returns form object
###    
          gadv_page.as_form.fill_required(:except => :with_words)
          gadv_page.as_form.each_required{|field|
            if field.label==:with_words
              field.watir_element.value.should eq ''
            else
              field.watir_element.value.should eq(gadv_page.as_form.default(field.label))
            end
          }

#Table wrapper
      before :all do
        PageObjectWrapper.domain = 'http://wiki.openqa.org'
      end
      let(:page_object){
        class WatirPage < PageObjectWrapper::Page
          attr_accessor :some_table
          @url="/display/WTR/HTML+Elements+Supported+by+Watir"
          expected_element :a, :text => 'HTML Elements Supported by Watir'
          def initialize visit=false 
            super visit
            @some_table = table(:class => 'confluenceTable')
          end
        end
        WatirPage
      }
##table definition
     
###has #table(how_find_hash) method to define a table on the page
            @some_table = table(:class => 'confluenceTable')
##table usage
      before :all do
        PageObjectWrapper.domain = 'http://wiki.openqa.org'
      end
      let(:page_object){
        class WatirPage < PageObjectWrapper::Page
          attr_accessor :some_table
          @url="/display/WTR/HTML+Elements+Supported+by+Watir"
          expected_element :a, :text => 'HTML Elements Supported by Watir'
          def initialize visit=false 
            super visit
            @some_table = table(:class => 'confluenceTable')
          end
        end
        WatirPage
      }
###has #cells method which returns all Watir table cells
          page = page_object.new(true)
          page.some_table.cells.first.should be_a(Watir::TableCell)
###has #has_cell?(text) method wich returns true if the table has a cell with specified text
          page = page_object.new(true)
          page.some_table.should have_cell('<td>')
###has #select(column_name, where_hash) method wich returns cell inside specified column wich corresponds to a specified where_hash
          page = page_object.new(true)
          cell = page.some_table.select('HTML tag', :where => {'Watir method' => 'cell'})
          cell.should be_a(Watir::TableCell)
          cell.text.should eq '<td>'
###is possible to specify just parts of column names in #select method
          cell = page.some_table.select('HTML', :where => {'Watir met' => 'cell'})

#Pagination wrapper

##pagination definition

###TODO
    Needs to be reimplemented. Current realization is fo rails apps only
##pagination usage

###TODO
    Needs to be reimplemented. Current realization is fo rails apps only

#TestData class
    	let(:user1){
    "login: user1
    email: user1@example.com
    password: secret1
    etc: other data"
    	}
    	let(:user2){
    "login: user2
    email: user2@example.com
    password: secret2
    etc: other data"
    	}
##is initialized with hash and generates dynamic attributes for an instance
    		dynamically_defined_user = PageObjectWrapper::TestData.new(YAML.load(user1))
    		dynamically_defined_user.login.should eq 'user1'
    		dynamically_defined_user.email.should eq 'user1@example.com'
    		dynamically_defined_user.password.should eq 'secret1'
    		dynamically_defined_user.etc.should eq 'other data'
##has .find method which allows finding dynamically defined objects
    		dynamically_defined_user1 = PageObjectWrapper::TestData.new(YAML.load(user1))
    		dynamically_defined_user2 = PageObjectWrapper::TestData.new(YAML.load(user2))
    		user1 = PageObjectWrapper::TestData.find(:login,'user1')
    		user1.email.should eq 'user1@example.com'
##has .each method which allows navigating between objects
    		dynamically_defined_user1 = PageObjectWrapper::TestData.new(YAML.load(user1))
    		dynamically_defined_user2 = PageObjectWrapper::TestData.new(YAML.load(user2))
    		PageObjectWrapper::TestData.each{|user|
    			user.etc.should eq 'other data'
    		}


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
page_object_wrapper
===================

Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.
