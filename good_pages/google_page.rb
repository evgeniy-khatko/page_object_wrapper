PageObjectWrapper.define_page(:google_page) do
  locator 'google.com'
  uniq_text_field :name => 'q'
end
