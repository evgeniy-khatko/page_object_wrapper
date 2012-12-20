PageObjectWrapper.define_page(:test_page_with_table) do
  locator 'http://www.cs.tut.fi/cgi-bin/run/~jkorpela/echo.cgi?hidden+field=42&foo=bar&text=Default+text.&textarea=Default+text.%0D%0A&radio=2&checkbox2=on&select1=two+%28default%29&select2=two+%28default%29'
  uniq_h1 :text => 'Echoing submitted form data'

  table(:test_table) do
    locator :index => 0
  end

  elements_set(:empty_set) do
  end
end
