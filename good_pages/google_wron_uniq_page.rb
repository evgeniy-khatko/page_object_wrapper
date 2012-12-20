PageObjectWrapper.define_page(:wrong_google_page) do
  locator 'google.com'
  uniq_element :id => 'foobar'
end
