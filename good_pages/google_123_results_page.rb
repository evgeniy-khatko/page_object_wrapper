PageObjectWrapper.define_page(:google_page) do
  locator 'google.com/...'
  uniq_input :id => 'gbqfq'

  pagination :pagination do
    locator "table(:id => 'nav').td.a(:text => '2')", '2'
  end
end

