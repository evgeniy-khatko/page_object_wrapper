PageObjectWrapper.define_page(:uniq_missing) do
  locator 'file://'+Dir.pwd+'/good_pages/some_test_page.html'
  uniq_text_field :id => 'foobar' 
end
