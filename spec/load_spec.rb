require 'spec_helper'

describe "PageObjectWrapper.compile" do
  let(:define_page_with_lots_of_errors){
    PageObjectWrapper.define_page('label') do
      locator ''
      uniq_element 'not a hash'

      elements_set('not a symbol') do
      end

      elements_set(:bad_elements) do
        element('') do
        end
        element(:e) do
          locator 'not a hash'
        end
        element(:e) do
          locator {}
        end
      end

      action('') do
        fire 'not a proc'
      end

      table('') do
      end
      table(:t) do
        header 'not an array'
      end

      pagination('') do
        locator 'not a hash'
      end
    end
  }

  describe "page load" do
    it "raises PageObjectWrapper::Load error with all errors described" do
      define_page_with_lots_of_errors
      expect{ PageObjectWrapper.load }.to raise_error(
        PageObjectWrapper::Load,
        "
        page_object(label):
        'label' not a Symbol
        '' not a meaningful String
        'not a hash' not a meaningful Hash
        page_object(label) -> elements_set(not a symbol):
        'not a symbol' not a Symbol
        is empty
        page_object(label) -> elements_set(:bad_elements) -> element():
        '' not a Symbol
        is empty
        page_object(label) -> elements_set(:bad_elements) -> element(:e):
        'not a hash' not a meaningful Hash
        page_object(label) -> elements_set(:bad_elements) -> element(:e):
        already defined
        {} not a meaningful Hash
        page_object(label) -> elements_set(:bad_elements) -> action():
        '' not a Symbol
        'not a proc' not a Proc
        page_object(label) -> elements_set(:bad_elements) -> table():
        '' not a Symbol
        is empty
        page_object(label) -> elements_set(:bad_elements) -> table(:t):
        'not an array' not an Array
        page_object(label) -> elements_set(:bad_elements) -> pagination():
        '' not a Symbol
        'not a hash' not a Hash
        "
      )
    end
  end
end
