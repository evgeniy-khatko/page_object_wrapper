require 'page_object_wrapper'

PageObjectWrapper.define_page('some_page_with_lost_of_errors') do
  locator ''
  uniq_element 'uniq element locator'

  elements_set('some elements_set label') do
  end

  elements_set(:bad_elements) do
    element('') do
      menu :fresh_food, Array.new
    end
    element(:e) do
      locator ':e element locator'
      menu 'a string', 'another string'
    end
    element(:e) do
      locator Hash.new
    end
  end

  action('','a string') do
  end

  validator('') do
  end

  action_alias('','a string'){ action 'unknown action'}

  table('') do
  end
  table(:some_table) do
    header []
  end

  pagination('') do
    locator 'pagination locator'
  end
end

