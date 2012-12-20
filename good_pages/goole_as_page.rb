PageObjectWrapper.define_page(:google_as_page) do
  locator '/advanced_search'
  uniq_text_field :name => 'as_q' 
end
