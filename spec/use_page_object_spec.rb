require 'spec_helper'
describe "feed_xxx method" do
  before(:all){PageObjectWrapper.start_browser}
  after(:all){PageObjectWrapper.stop_browser}
  let(:some_test_page){PageObjectWrapper.open_page(:some_test_page)}

  it "is created after an ElementsSet with a label xxx has been created" do
    some_test_page.should respond_to(:feed_test_elements)
  end

  it "takes one argument - type of the food being fed (:missing_food, :fresh_food)" do
    begin
      some_test_page.feed_test_elements(:first_arg, :second_arg)
    rescue Exception => e
      e.should be_a ArgumentError
    end
  end

  describe "performing actions on all elements of the xxx" do
    before(:all){
      PageObjectWrapper.start_browser
      test_page = PageObjectWrapper.open_page(:some_test_page)
      some_test_page.feed_test_elements(:fresh_food)
    }
    after(:all){PageObjectWrapper.stop_browser}

    it "set element if element is Watir::CheckBox or Watir::Radio" do
      some_test_page.checkbox.should be_set
      some_test_page.radio.should be_set
    end

    it "select(provided_food) if element is Watir::Select" do
      some_test_page.select_list.should be_selected("one")
    end

    it "set(provided_food) in other cases, if element respond_to(:set)" do
    end

    it "raises PageObjectWrapper::UnableToFeedObject exception otherwise" do
    end
  end

  it "feeds element with regular (default) food if provided food is not set for the element" do
  end

  it "returns PageObject instance it's being called from" do
  end
end
end
