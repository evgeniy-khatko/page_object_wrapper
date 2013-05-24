PageObjectWrapper.define_page(:some_test_page) do
  #locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
  locator 'file://'+Dir.pwd+'/good_pages/some_test_page.html'
  uniq_h1 :text => 'Testing display of HTML elements'

  text_field(:tf_standalone) do
    locator :id => 'f1'
    menu :loud, 'tf food'
  end

  button(:standalone_cool_button_with_default_press_action) do
    locator :name => 'foo'
    menu :loud, 'try to feed me!'
  end

  button(:standalone_cool_button) do
    locator :name => 'foo'
    press_action :click
  end

  button(:invalid_press_action_button) do
    locator :name => 'foo'
    press_action :press
  end

  button(:invalid_button) do
    locator :name => 'bar'
  end

  elements_set(:test_elements) do

    button(:cool_button) do
      locator :name => 'foo'
    end

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
    header [:country, :total_area, :land_area, :link, :checkbox]
  end

  validator(:textarea_value) do |expected|
    textarea(:id => 'f2').value == expected
  end

  validator :tekst_pervoi_ssylki do
    text = textarea(:id => 'f2').when_present.value
	end

  pagination :some_pagination do
    locator "link(:text => 2)", 2
  end
end
