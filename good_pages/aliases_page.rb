PageObjectWrapper.define_page(:page_with_aliases) do
  locator 'file://'+Dir.pwd+'/good_pages/some_test_page.html'
  uniq_h1 :text => 'Testing display of HTML elements'
  label_alias :page_name_alias
  label_alias :another_page_name_alias

  text_field(:text_field) do
    label_alias :text_field_alias
    locator :id => 'f1'
    menu :loud, 'tf food'
  end

  button(:button) do
    label_alias :button_alias
    locator :name => 'foo'
    menu :loud, 'try to feed me!'
  end

  elements_set(:eset) do
    label_alias :eset_alias

    textarea(:text_area) do
      label_alias :text_area_alias
      locator :id => 'f2'
      menu :loud, 'ta food'
    end

    radio(:radio_button){ 
      label_alias :radio_button_alias
      locator :id => 'f3' 
      menu :loud, true
      menu :quite, false
    }
    
    checkbox(:checkbox){ 
      label_alias :checkbox_alias
      locator :id => 'f5'
      menu :loud, true 
      menu :quite, false
    }

    select(:select_list) do
      label_alias :select_list_alias
      locator :id => 'f10'
      menu :loud, 'one'
      menu :quite, 'two (default)'
    end
  end

  action(:press_cool_button, :test_page_with_table) do
    button(:name => 'foo').when_present.click
  end

  table(:table) do
    label_alias :table_alias
    locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
    header [:country, :total_area, :land_area, :link, :checkbox]
  end

  pagination :pagination do
    label_alias :pagination_alias
    locator "link(:text => 2)", 2
  end
end
