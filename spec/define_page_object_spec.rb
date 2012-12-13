require 'spec_helper'

describe "define_page_object" do

  let(:page_object){
    PageObjectWrapper.define_page(:some_test_page) do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
      uniq_element :h1 => 'Testing display of HTML elements'

      elements_set(:test_elements) do
        element(:text_field) do
          locator :id => 'f1'
          fresh_food 'some fresh food'
        end

        element(:text_area) do
          locator :id => 'f2'
          missing_food 'some missing food'
        end

        element(:radio) do
          locator :id => 'f3'
        end

        element(:checkbox) do
          locator :id => 'f5'
        end

        element(:select_list) do
          locator :id => 'f10'
          fresh_food 'one'
        end

        element(:another_select_list) do
          locator :id => 'f11'
          missing_food 'four'
        end
      end

      action(:press_cool_button) do
        next_page :test_page_with_table
        fire{
          button(:name => 'foo').click
        }
      end
    end
  }

  it "creates new PageObject instance with a label*, locator* and uniq_element" do
    page_object.should be_a(PageObject)
    page_object.label.should eq(:some_test_page)
    page_object.locator.should eq('http://www.cs.tut.fi/~jkorpela/www/testel.html')
  end

  it "pushes created PageObject instance to a PageObject.pages array" do
    PageObject.pages.should include(page_object)
  end

  context "ElementsSet creation" do
    it "creates new ElementsSet with a label* and corresponding getter to get created element" do
      page_object.should respond_to(:test_elements)
      page_object.test_elements.should be_a(ElementsSet)
      page_object.test_elements.should respond_to(:label)
    end

    it "pushes new ElementsSet instance to a PageObject.esets array" do
      page_object.esets.collect(&:label_value).should include(:test_elements)
    end

    it "creates at least one Element instance with a label*, locator*, fresh_food, missing_food, action and adds corresponding getter to created element" do
      page_object.should respond_to(:text_field)
      page_object.should respond_to(:text_area)
      page_object.should respond_to(:radio)
      page_object.should respond_to(:checkbox)
      page_object.should respond_to(:select_list)
      page_object.should respond_to(:another_select_list)
      page_object.text_field.should be_a(Element)
      page_object.text_field.should respond_to(:label)
      page_object.text_field.should respond_to(:locator)
      page_object.text_field.should respond_to(:fresh_food)
      page_object.text_field.should respond_to(:missing_food)
    end

    
    it "pushes created element(s) to ElementsSet.elements array" do
      page_object.elements.collect(&:label_value).should eq([:text_field, :text_area, :radio, :checkbox, :select_list, :another_select_list])
    end

    describe "feed_xxx_elements method" do
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
          puts e.message
        end
      end

      describe "performing actions on all elements of the xxx" do
        it "set element if element is Watir::CheckBox or Watir::Radio" do
        end

        it "select(provided_food) if element is Watir::Select" do
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

  context "Action creation" do
    it "creates new Action instance with a label* and a next_page*" do
    end

    it "saves a fire block for future use in browser context" do
    end

    describe "fire_xxx_action method" do
      it "executes all action steps in current browser's context" do
      end

      it "returns a PageObject instance which corresponds to the :next_page label" do
      end
    end
  end

  context "Table creation" do
    it "creates new Table instance with a label* locator* and a header*" do
    end

    it "pushes created table to a PageObject.tables array" do
    end

    describe "select_from_xxx(:header_column, {:another_header_column => value}) method" do
      it "is created after a Table nstance with the label xxx has been created" do
      end

      it "returns Watir::TableCell as a search result" do
      end

      it "allows usage of regular expressions for :header_column and :another_header_column" do
      end

      it "raises Watir::ElementNotFound if found result is nil" do
      end
    end
  end

  context "Pagination creation" do
    it "creates new Pagination instance with a label* and locator*" do
    end

    it "pushes created pagination to a PageObject.paginations array" do
    end

    describe "each_xxx_subpage{} method" do
      it "is created after a pagination with the label xxx has been created" do
      end

      it "navigates through all pagination pages and yields provided block" do
      end
    end

    describe "open_xxx_subpage(N) method" do
      it "is created after a pagination with the label xxx has been created" do
      end

      it "navigates browser to a pagination page number N" do
      end

      it "raises Watir::ElementNotFound if subpage number N has not been found" do
      end
    end
  end

  context "another PageObject instance methods" do
    describe "feed_all_elements" do
      it "it's a method of a PageObject" do
      end

      it "takes one argument - type of the food being fed (:missing_food, :fresh_food)" do
      end

      it "populates all elements of the PageObject instance which respond_to :set with provided food" do
      end

      it "feeds element with regular (default) food if provided food is not set for the element" do
      end

      it "returns PageObject instance it's being called from" do
      end
    end
  end
end
