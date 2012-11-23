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

##Page object
#PageObjectWrapper
    has .start_browser method which puts Watir::Browser.new to Page.accessor by default
    has .stop_browser method which closes browser
    has .restart_browser method which restart current browser
    has .domain= method which reprsents the domain of DUT
    has .timeout= method which sets implicit timeout for webdriver (default is 5 sec) (PENDING: not working yet)
#GoogleSearchPage class instance in general
    class has @url class variable which can be treated as Page specific path inside current domain
      should eq "/"
    init with 'true' is similar to openning page in browser
      should eq "Google"
    init with 'false' just returns new instanse, but does not opens browser on that page
      should not eq "Google"
#expected element
    should raise error when trying to init google_search_with_wrong_expected_element_page_class
    should init google_search_with_correct_expected_element_page_class successfully
#creation of a PageObject method
    return value should be another PageObject instance
      should be a kind of GoogleAdvancedSearchPage

Pending:
  ##Page object#PageObjectWrapper has .timeout= method which sets implicit timeout for webdriver (default is 5 sec)
    # not working yet

##Form wrapper
#form definition
    is defined as #form(TargetPage, how_find_hash)
    has #editable(:field_type, how_find_hash, :label, default_value, required?) method to set form's fields
      :field_type sets corresponding watir element type
      how_find_hash is used to locate corresponding watir element on the page
      :label is used to reffer to the form field after definition
      default_value is used to populate fields with default test data
      required = true | false and indicates if the field is required
    has #submitter(:field_type, how_find_hash, how_click_mehtod, click_params) method to set form's submitter
      :field_type sets corresponding watir element type
      how_find_hash is used to locate corresponding watir element on the page
      how_click_mehtod is used to tell Waitr the method which should be applied to click the submitter
      click_params set parameters for the how_click_mehtod
#form usage
    has #submit(flag) method which submits form
      if flag = true than TargetPage instance is returned
      if flag = false than CurrentPage instance is returned
      if submitter is defined, than it's used to submit the form, otherwise standart Watir::Form submit is used
    has #each method which allows navigating between form fields
    has #each_required method which allows navigating between form required fields (corresponding watir elements)
    has #fill_only(:label => value) method which populated form's :label field with 'value'
      method returns form object
    has #fill_all(:except => labels_array | label) method which populated all form's fields with default values
      if except_hash is not nil than provided fields are not populated
      method returns form object
    has #fill_required(:except => labels_array | label) method which populated all required form's fields with default values
      if except_hash is not nil than provided fields are not populated
      method returns form object
    field's watir elements can be accessed by labels
      should be a kind of Watir::TextField
    fields default values set during form definition can be retrieved with #default(:label) method
      should eq "@find_form default value"

##Table wrapper
#table definition
    has #table(how_find_hash) method to define a table on the page
#table usage
    has #cells method which returns all Watir table cells
    has #has_cell?(text) method wich returns true if the table has a cell with specified text
    has #select(column_name, where_hash) method wich returns cell inside specified column wich corresponds to a specified where_hash
    is possible to specify just parts of column names in #select method

##Pagination wrapper
#pagination definition
    TODO (PENDING: Needs to be reimplemented. Current realization is fo rails apps only)
#pagination usage
    TODO (PENDING: Needs to be reimplemented. Current realization is fo rails apps only)

##TestData class
  is initialized with hash and generates dynamic attributes for an instance
  has .find method which allows finding dynamically defined objects
  has .each method which allows navigating between objects

*please look into specs for more detailed usage examples*

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
page_object_wrapper
===================

Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.
