# PageObjectWrapper

Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.  
*Warning:* version 1.0 and higher are not compatible with older versions

## Installation

Install Firefox on your system

Add this line to your application's Gemfile:

    gem 'page_object_wrapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install page_object_wrapper

## Usage
#####please look into specs for more detailed usage examples

### Basic usecase is following
1. Define page object with PageObjectWrapper.define\_page
2. Use defined page object inside your tests with usefull page\_object #methods

### Basic principles of a PageObjectWrapper
- there are following objects: page\_object, elements\_set with elements, table, action, pagination  
- a page_object contains elements\_sets, tables, actions, paginations
- an elements\_set contains elements
- every object has a :label
- a label identifies the object

Here in the structure of PageObjectWrapper:
![PageObjectWrapper scheme](https://raw.github.com/evgeniy-khatko/page_object_wrapper/master/img/scheme.png)

where required attributes are marked with (\*)  
optional arguments are enclosed with [ ]


### Examples

#### definition example

      PageObjectWrapper.define_page(:some_test_page) do
        locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
        uniq_h1 :text => 'Testing display of HTML elements'

        elements_set(:test_elements) do
          text_field(:tf) do
            locator :id => 'f1'
            menu :user_defined, 'some food'
          end

          textarea(:ta) do
            locator :id => 'f2'
          end
          
          select(:s1) do
            locator :id => 'f10'
            menu :fresh_food, 'one'
            menu :missing_food, 'three'
          end

          select(:s2) do
            locator "form(:action => 'http://www.cs.tut.fi/cgi-bin/run/~jkorpela/echo.cgi').select(:id => 'f11')"
            menu :fresh_food, 'one'
          end

          checkbox(:cb){ locator :id => 'f5' }
          radio(:rb){ locator :id => 'f3' }
        end

        action(:press_cool_button, :test_page_with_table) do
          button(:name => 'foo').when_present.click
        end

        action(:fill_textarea, :some_test_page) do |fill_with|
          data = (fill_with.nil?)? 'Default data' : fill_with
          textarea(:id => 'f2').set data
        end

        action_alias(:fill_textarea_alias, :some_test_page){ action :fill_textarea }

        table(:table_without_header) do
          locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
        end

        table(:table_with_header) do
          locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
          header [:country, :total_area, :land_area]
        end

        pagination(:some_pagination) do
          locator :xpath => ''
        end

        validator(:textarea_value) do |expected|
          textarea(:id => 'f2').value == expected
        end
      end

here we have defined a page object with locator (url) = 'http://www.cs.tut.fi/~jkorpela/www/testel.html'  
- uniq\_xxx is used to define a uniq element on that page, which uniquely identifies the page from other pages  
- uniq\_xxx is being checked when openning the page with PageObjectWrapper.open\_page and when running an page\_object.action  
- all defined elements have labels
- action and action\_alias defined with labels and next\_pages
- validator defined with label

#### openning the page
*preconditions*  
There is a directory, where we've defined a page\_object inside a \*\_page.rb file

1. specify browser to be used by PageObjectWrapper  
  
       @b = Watir::Browser.new  
       PageObjectWrapper.use_browser @b  
2. load defined pages  
  
       PageObjectWrapper.load("path/to/pages/directory")  
3. open page in browser  
  
       test_page = PageObjectWrapper.open_page(:some_test_page)  

*comments*
- it's possible to use any Watir::Browser with any profile
- it's possible to use any Webdriver, which behaves like Watir::Browser (meaning that Webdriver uses similar methods for locating elements and working with them)    
- .load method validates all pages, defined in specified directory inside any \*\_page.rb file
- it's possible to define several page objects in one file
- .open\_page method takes page label, directs browser to that page and returns corresponding page\_object
- PageObjectWrapper.current\_page points to the opened page\_object
- it's possible to set page\_object locator in 2 different ways: specifying full url (like in example) or specifying PageObjectWrapper.domain and page\_object local path (like in specs)
- it's possible to set dynamic urls for pages, e.g.  
  
        PageObjectWrapper.define_page(:google){ locator 'www.google.com/:some_param' }  
        PageObjectWrapper.open_page(:google, :some_param => 'advanced_search') # => 'http://google.com/advanced_search'  

#### page\_object.xxx 
*parameters*  
no  
*returns*  
Watir::XXX element  
  
Defined elements can be accessed with their labels.
- element from an element\_set is corresponds to real Watir::Element
- elemets\_set corresponds to an Array of Watir::Element  

*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

      tp.tf # => Watir::TextField
      tp.rb # => Watir::Radio
      tp.test_elements # => Array of Watir elements
      tp.table_with_header # => Watir::Table



#### feed\_xxx 
*parameters*  
:fresh\_food, :missing\_food  
*returns*  
current\_page  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

    context "argument = :fresh_food":
      it "populates all xxx elements with :fresh_food":
        tp = PageObjectWrapper.current_page
        tp.feed_test_elements(:fresh_food)

    context "argument = nil":
      it "populates all xxx elements with :fresh_food":
        tp = PageObjectWrapper.current_page
        tp.feed_test_elements

    context "argument = :missing_food":
      it "populates all xxx elements with :missing_food":
        tp = PageObjectWrapper.open_page(:some_test_page)
        tp.feed_test_elements(:missing_food)

#### xxx\_menu  
*parameters*  
:food\_type  
*returns*  
food value for this type which is defined in page\_object  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser  

    tp.tf_menu(:fresh_food) # => 'default fresh food' 
    tp.tf_menu(:user_defined) # => 'some food'

#### fire\_xxx 
*parameters*  
optional arguments defined inside action  
*returns*  
next\_page from xxx action  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

    it "executes fire_block in Watir::Browser context":
      tp = PageObjectWrapper.open_page(:some_test_page)
      tp.fire_fill_textarea

    it "can be invoked with parameters":
      tp = PageObjectWrapper.current_page
      tp.fire_fill_textarea('User defined data')

    it "returns next_page":
      tp = PageObjectWrapper.current_page
      np = tp.fire_press_cool_button

    context "xxx is alias":
      it "executes corresponding action":
        tp = PageObjectWrapper.open_page(:some_test_page)
        tp.fire_fill_textarea_alias

#### validate\_xxx 
*parameters*  
optional arguments defined inside action  
*returns*  
anything block inside xxx validator returns
it's expected that validator returns true | false
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

      tp = PageObjectWrapper.open_page(:some_test_page)
      tp.fire_fill_textarea
      tp.validate_textarea_value('Default data').should be(true)

      tp = PageObjectWrapper.current_page
      tp.fire_fill_textarea('User defined data')
      tp.validate_textarea_value('User defined data').should be(true)

#### select\_from\_xxx  
*parameters*  
:column\_1, :column\_2 => search\_value, :optional\_next\_page  
*returns*  
Watir::TableCell if next\_page not specified  
next\_page if it is specified  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser  
its syntax is close to SQL *'select column1 from page\_object.some\_table where column2 = string\_or\_regexp'*     
      page\_object.select\_from\_xxx( :column1, :column2 => 'string\_or\_regexp' )    
correct arguments are:  
:column1 is a column value from which you want to receive   
:column2 is a column which is used to get specific row   

    context "where == nil":
      it "returns last row value from provided column":
        tp.select_from_table_without_header(:column_0).text.should eq 'Sweden'
        tp.select_from_table_without_header(:column_1).text.should eq '449,964'
        tp.select_from_table_without_header(:column_2).text.should eq '410,928'

    context "where not nil":
      context "found by String":
        it "returns found cells":
          tp.select_from_table_without_header(:column_0, :column_1 => '103,000').text.should eq 'Iceland'
          tp.select_from_table_with_header(:country, :total_area => '337,030').text.should eq 'Finland'
        it "returns nil":
          tp.select_from_table_without_header(:column_0, :column_1 => '123').should eq nil
          tp.select_from_table_with_header(:country, :total_area => '123').should eq nil
      context "found by Regexp":
        it "returns found cells":
          tp.select_from_table_without_header(:column_0, :column_1 => /103/).text.should eq 'Iceland'
          tp.select_from_table_with_header(:country, :total_area => /337/).text.should eq 'Finland'
        it "returns nil":
          tp.select_from_table_without_header(:column_0, :column_1 => /123/).should eq nil
          tp.select_from_table_with_header(:country, :total_area => /123/).should eq nil
        context "found by row number":
          it "returns found cells":
            tp.select_from_table_without_header(:column_0, :row => 2).text.should eq 'Iceland'
            tp.select_from_table_with_header(:country, :row => 3).text.should eq 'Norway'
          it "returns nil":
            tp.select_from_table_with_header(:country, :row => 123).should eq nil

      context "next_page specified":
        context "found by String":
          it "returns found cells":
            tp.select_from_table_without_header(:column_0, {:column_1 => '103,000'}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
        context "not found by String":
          it "returns nil":
            tp.select_from_table_without_header(:column_0, {:column_1 => '123'}, :some_test_page).should eq nil
        context "found by row number":
          it "returns found cells":
            tp.select_from_table_without_header(:column_0, {:row => 2}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
            tp.select_from_table_with_header(:country, {:row => 3}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
          it "returns nil":
            tp.select_from_table_with_header(:country, {:row => 123}, :some_test_page).should eq nil

#### each\_xxx
TODO
#### open\_xxx
TODO
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request  

##page\_object\_wrapper
Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.
