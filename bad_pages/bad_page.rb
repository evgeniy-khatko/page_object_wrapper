require 'page_object_wrapper'

PageObjectWrapper.define_page('some_page_with_lost_of_errors') do
  locator ''
  uniq_element 'uniq element locator'

  elements_set('some elements_set label') do
  end

  elements_set(:bad_elements) do
    element('') do
    end
    element(:e) do
      locator ':e element locator'
    end
    element(:e) do
      locator Hash.new
    end
  end

  action('') do
    fire{'mailformed proc'}
  end

  table('') do
  end
  table(:some_table) do
    header 'table header'
  end

  pagination('') do
    locator 'pagination locator'
  end
end

