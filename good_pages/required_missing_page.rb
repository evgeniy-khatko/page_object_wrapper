PageObjectWrapper.define_page(:required_missing) do
  locator 'file://'+Dir.pwd+'/good_pages/some_test_page.html'

  text_field(:tf) do
    locator :id => 'foobar'
    required true
  end

end
