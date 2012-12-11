require 'spec_helper'

describe "define_page_object" do
  it "accepts two arguments - page_object label and a block" do
  end

  it "creates new PageObject with a label*, locator* and uniq_element" do
  end

  it "pushes created PageObject instance to a PageObjectWrapper.pages array" do
  end

  context "ElementsSet creation" do
    it "creates new ElementsSet with a label*" do
    end

    it "pushes new ElementsSet to a PageObject.element_sets array" do
    end

    it "creates at least one Element with a label*, locator*, fresh_food, missing_food, action" do
    end
    
    it "pushes created element to ElementsSet.elements array" do
    end
  end

  context "Action creation" do
    it "creates new Action with a label*, next_page*" do
    end

    it "creates at least one step with integer identifier*" do
    end

    its "each step has the access to the browser instance" do
    end
  end

  context "Table creation" do
    it "creates new Table instance with a label* locator* and a header*" do
    end

    it "pushes created table to a PageObject.tables array" do
    end
  end

  context "Pagination creation" do
    it "creates new Pagination instance with a label* and locator*" do
    end

    it "pushes created pagination to a PageObject.paginations array" do
    end
  end

  context "dynamic PageObject instance methods" do
    describe "feed_xxx_elements" do
      it "is created after an ElementsSet with a :label xxx has been created" do
      end

      it "takes one argument - type of the food being fed (:missing_food, :fresh_food)" do
      end

      it "populates all elements of the :xxx which respond_to :set with provided food" do
      end

      it "feeds element with regular (default) food if provided food is not set for the element" do
      end

      it "returns PageObject instance it's being called from" do
      end
    end

    describe "feed_all_element" do
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

    describe "fire_xxx_action" do
      context "if created after an action xxx has been created" do
        it "executes all action steps in current browser's context" do
        end
      end

      context "if created after an element with :action was defined inside an :elements_set" do
        it "if executes element event provided to the action" do
        end
      end

      it "returns a PageObject instance which corresponds to the :next_page label" do
      end
    end

    describe "select_from_xxx(:header_column, {:another_header_column => value})" do
      it "is created after a table with the label xxx has been created" do
      end

      it "returns Watir::TableCell as a search result" do
      end

      it "allows usage of regular expressions for :header_column and :another_header_column" do
      end

      it "raises Watir::ElementNotFound if found result is nil" do
      end
    end

    describe "each_xxx_subpage{}" do
      it "is created after a pagination with the label xxx has been created" do
      end

      it "navigates through all pagination pages and yields provided block" do
      end
    end

    describe "open_xxx_subpage(N)" do
      it "is created after a pagination with the label xxx has been created" do
      end

      it "navigates browser to a pagination page number N" do
      end

      it "raises Watir::ElementNotFound if subpage number N has not been found" do
      end
    end
  end
end
