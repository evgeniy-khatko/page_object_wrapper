PageObjectWrapper.define_page(:dynamic_url_page) do
  locator ':domain/:path'
  uniq_text_field :name => 'as_q' 
end
