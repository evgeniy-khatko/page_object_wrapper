PageObjectWrapper.define_page(:some_test_page) do
  #locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
  locator 'file://'+Dir.pwd+'/good_pages/some_test_page.html'
  uniq_h1 :text => 'Testing display of HTML elements'

  elements_set(:test_elements) do
    text_field(:tf) do
      locator :id => 'f1'
      menu :loud, 'tf food'
    end

    textarea(:ta) do
      locator :id => 'f2'
      menu :loud, 'ta food'
    end

    radio(:rb1){ 
      locator :id => 'f3' 
      menu :loud, true
      menu :quite, false
    }
    
    radio(:rb2){ 
      locator :id => 'f4'
      menu :loud, false 
    }

    checkbox(:cb1){ 
      locator :id => 'f5'
      menu :loud, true 
      menu :quite, false
    }

    checkbox(:cb2){ 
      locator :id => 'f6'
      menu :loud, false 
    }

    select(:s1) do
      locator :id => 'f10'
      menu :loud, 'one'
      menu :quite, 'two (default)'
    end

    select(:s2) do
      locator "form(:action => 'http://www.cs.tut.fi/cgi-bin/run/~jkorpela/echo.cgi').select(:id => 'f11')"
      menu :loud, 'one'
    end
  end

  action(:press_cool_button, :test_page_with_table) do
    button(:name => 'foo').when_present.click
  end

  action(:fill_textarea, :some_test_page) do |fill_with|
    data = (fill_with.nil?)? 'Default data' : fill_with
    textarea(:id => 'f2').set data
  end

  action :fill_textarea_with_returned_value do |fill_with|
    data = (fill_with.nil?)? 'Default data' : fill_with
    textarea(:id => 'f2').set data
    data
  end 

  action_alias(:fill_textarea_alias, :some_test_page){ action :fill_textarea }
  action_alias(:fill_textarea_with_returned_value_alias){ action :fill_textarea_with_returned_value }

  table(:table_without_header) do
    locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
  end

  table(:table_with_header) do
    locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
    header [:country, :total_area, :land_area]
  end

  validator(:textarea_value) do |expected|
    textarea(:id => 'f2').value == expected
  end

  pagination :some_pagination do
    locator "link(:text => 2)", 2
  end
end
