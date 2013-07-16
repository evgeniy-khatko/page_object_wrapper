PageObjectWrapper.define_page(:test_page_with_table) do
  locator 'test_page_with_table.html'
  uniq_h1 :text => 'Echoing submitted form data'

  table(:test_table) do
    locator :index => 0
  end

  elements_set(:empty_set) do
  end
end
