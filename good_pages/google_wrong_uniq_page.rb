PageObjectWrapper.define_page(:wrong_google_page) do
  locator 'google.com'
  uniq_text_field :id => 'foobar'
end
