PageObjectWrapper.define_page(:some_test_page) do
  locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
  uniq_h1 :text => 'Testing display of HTML elements'

  elements_set(:test_elements) do
    text_field(:tf) do
      locator :id => 'f1'
      missing_food 'some missing food'
      fresh_food 'some fresh food'
    end

    textarea(:ta) do
      locator :id => 'f2'
    end
    
    select(:s1) do
      locator :id => 'f10'
      fresh_food 'one'
      missing_food 'three'
    end

    select(:s2) do
      locator :id => 'f11'
      fresh_food 'one'
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
