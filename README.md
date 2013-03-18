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

#### definition examples
##### define a page object with url and some elements
    PageObjectWrapper.define_page :some_test_page do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html' # url
      
      text_field(:tf) do # defines a text_field
        locator :id => 'f1' # element locator (can be Hash or String)
        menu :user_defined, 'some food' # input data with type :user_defined for this element
      end

      select(:s1) do # select list
        locator :id => 'f10'
        menu :fresh_food, 'one'
        menu :missing_food, 'three'
      end

      table(:table_with_header) do # table with predifined header
        locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
        header [:country, :total_area, :land_area] # header will be used later inside #select_from_xxx calls
      end
    end

##### elements can be included into element\_sets
    PageObjectWrapper.define_page :some_test_page do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'

      elements_set :test_elements do
        text_field(:tf) do
          locator :id => 'f1'
          menu :user_defined, 'some food'
        end

        textarea :ta do
          locator :id => 'f2'
        end
        
        select :s1 do
          locator :id => 'f10'
          menu :fresh_food, 'one'
          menu :missing_food, 'three'
        end
      end
    end

##### each element can be marked as required 
    PageObjectWrapper.define_page :some_test_page do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'

      text_field :tf do
        locator :id => 'f1'
        menu :user_defined, 'some food'
        required true # will be checked for presence upon page load
      end
    end

*if all pages are similar through out the web app, it's possible to additionaly set a number of uniq elements   
which will be checked for presence as well*

    PageObjectWrapper.define_page :some_test_page_similar_to_previous do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'

      uniq_h1 :text => 'Testing display of HTML elements'

      text_field :tf do
        locator :id => 'f1'
        menu :user_defined, 'some food'
        required true # will be checked for presence upon page load
      end
    end

##### it's possible to define action and its aliases inside pages
*actions are being executed in browser context*

    PageObjectWrapper.define_page :some_test_page do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
      uniq_h1 :text => 'Testing display of HTML elements'

      action(:press_cool_button, :test_page_with_table) do # this action returns :test_page_with_table object after execution
        button(:name => 'foo').when_present.click
      end

      action :fill_textarea_with_returned_value do |fill_with|  # this action returns 'data' 
        data = (fill_with.nil?)? 'Default data' : fill_with     # (because returned page object is not specified)
        textarea(:id => 'f2').set data
        data
      end 

      action_alias(:fill_textarea_alias, :some_test_page){ action :fill_textarea }
      action_alias(:fill_textarea_with_returned_value_alias){ action :fill_textarea_with_returned_value }

      table(:table_without_header) do
        locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
      end
    end

### other definition examples can be found inside 'good\_pages', 'bad\_pages' folders

#### PageObjectWrapper.open\_page - opens page with specified label
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

#### page\_object.xxx - returns corresponding Watir element defined inside page\_object
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



#### feed\_xxx - inserts data inside an element, an elements\_set or all elements of the page
*parameters*  
menu type, specified inside page\_object (optional)
*returns*  
current\_page  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

      context "menu not specified":
        it "does nothing":
          tp.feed_test_elements
          browser.text_field(:id => 'f1').value.should eq 'Default text.'
          ....

      describe "basic usage": 
        it "FEEDS elements which have provided menu inside defimition":
          tp.feed_test_elements(:loud)
          browser.text_field(:id => 'f1').value.should eq 'tf food'
          ....

        it "feeds ONLY elements which has provided menu":
          tp.feed_test_elements(:quite)
          browser.text_field(:id => 'f1').value.should eq 'Default text.'
          ....

        it "overrides defined menu when passing arguments":
          tp.feed_test_elements(:loud, :tf => 'cheef menu', :rb1 => false, :rb2 => true, :cb2 => true, :s2 => 'three')
          browser.text_field(:id => 'f1').value.should eq 'cheef menu'
          ....

        it "can be used without providing a menu":
          tp.feed_test_elements(:tf => 'cheef menu', :rb2 => true, :cb2 => true, :s2 => 'three')
          browser.text_field(:id => 'f1').value.should eq 'cheef menu'
          ....

#### xxx\_menu - returns corresponding data, defined inside xxx element
*parameters*  
:food\_type  
*returns*  
food value for this type which is defined in page\_object  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser  

    tp.tf_menu(:loud) # => 'tf food' 
    tp.rb1_menu(:loud) # => 'true' # pay attention that String is being returned (not true, TrueClass)

#### fire\_xxx - executes action with label xxx
*parameters*  
optional arguments defined inside action  
*returns*  
next\_page from xxx action  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

    it "can be invoked with parameters":
      tp = PageObjectWrapper.current_page
      tp.fire_fill_textarea('User defined data')

    context "next_page == nil":
      it "returns action returned value":
        tp = PageObjectWrapper.current_page
        data = tp.fire_fill_textarea_with_returned_value('data to fill with')
        tp.validate_textarea_value(data).should be(true)

    context "xxx is alias":
      it "executes corresponding action":
        tp = PageObjectWrapper.open_page(:some_test_page)
        tp.fire_fill_textarea_alias

#### press\_xxx - presses element with label xxx
*parameters*  
no
*returns*  
pressed watir element
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

      it "returns pressed watir element"
        tp.press_cool_button.should be_a Watir::Button

      it "really presses the element"
        tp.press_standalone_cool_button_with_default_press_action
        PageObjectWrapper.current_page?(:test_page_with_table).should be_true

#### validate\_xxx - executes validator with label xxx
*parameters*  
optional arguments defined inside action  
*returns*  
anything block inside xxx validator returns
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser

      tp = PageObjectWrapper.open_page(:some_test_page)
      tp.fire_fill_textarea data
      tp.validate_textarea_value.should eq data

#### select\_from\_xxx - tries to select data from table with label xxx
*parameters*  
:column\_1, :column\_2 => search\_value, :optional\_next\_page  
*returns*  
Watir::TableCell if next\_page not specified  
next\_page if it is specified  
  
*preconditions*  
**tp** is a :some\_test\_page object opened in the browser (url = https://raw.github.com/evgeniy-khatko/page_object_wrapper/master/img/scheme.png)   
*Method's syntax is close to SQL:*  
      page\_object.select\_from\_xxx( :column1, :column2 => 'string\_or\_regexp' )    
*correct arguments are:*  
:column1 *is a column value from which you want to receive   
:column2 *is a column which is used to get specific row   

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

#### each\_xxx - alternately opens each pagination subpage
      context "correct parameters ( limit = 3 )":
        it "opens browser on subeach page and yields corresponding page_object":
          gp = PageObjectWrapper.open_page(:google_pagination)
          counter = 0
          gp.pagination_each( :limit => 3 ){ |subpage| 
            counter += 1
            subpage.should be_a PageObject 
            subpage.validate_current_number?(counter).should be_true
          }
#### open\_xxx - opens pagination subpage number N
      context "correct parameters":
        it "opens browser on provided subpage returns corresponding page_object":
          n = 10
          yp = PageObjectWrapper.open_page(:yandex_pagination)
          yp.pagination_open(n).should be_a PageObject
          yp.validate_current_number?(n).should be_true
          gp = PageObjectWrapper.open_page(:google_pagination)
          gp.pagination_open(n).should be_a PageObject
          gp.validate_current_number?(n).should be_true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request  

##page\_object\_wrapper
Wraps watir-webdriver with convenient testing interface, based on PageObjects automation testing pattern. Simplifies resulting automated test understanding.
