PageObjectWrapper.define_page(:another_test_page) do
  locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
  uniq_h1 :text => 'Testing display of HTML elements'

  elements_set(:test_elements) do
    select(:s1) do
      locator :id => 'f10'
      fresh_food 'not in select list'
      missing_food 'not in select list'
    end
  end
end

