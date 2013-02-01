PageObjectWrapper.define_page(:google_page) do
  locator 'google.com'
  uniq_text_field :name => 'g'

  action :find_by_query, :google_results_page do |query|
    text_field(:name => 'q').set query
    button(:name => 'btnK').when_present.click
  end
end
