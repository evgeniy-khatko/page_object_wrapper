require 'page_object_wrapper'

PageObjectWrapper.define_page('some_page_with_lost_of_errors') do
  locator ''
  uniq_element 'uniq element locator'

  elements_set('some elements_set label') do
  end

  text_field :bad_required_flad do
    required 'a string'
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

  text_field :dublicate_tf do
    label_alias :dublicate_tf
  end

  text_field :another_dublicate_tf do
    label_alias 'not a symbol'
  end

  textarea :area do
    label_alias :another_dublicate_tf
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
    locator Hash.new, 1
  end
end

#PageObjectWrapper.define_page :dublicate_label do
#  label_alias :dublicate_label
#end
