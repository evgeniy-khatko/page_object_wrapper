require 'spec_helper'
require 'shared_examples'

describe "define_page_object" do

  let(:page_object){
    PageObjectWrapper.define_page(:some_test_page) do
      locator 'http://www.cs.tut.fi/~jkorpela/www/testel.html'
      uniq_h1 :text => 'Testing display of HTML elements'

      elements_set(:test_elements) do
        text_field(:text_field) do
          locator :id => 'f1'
          missing_food 'some missing food'
        end
      end

      action(:press_cool_button) do
        next_page :test_page_with_table
        fire{
          button(:name => 'foo').click
        }
      end

      table(:table_without_header) do
        locator :summary => 'Each row names a Nordic country and specifies its total area and land area, in square kilometers'
      end

      pagination(:some_pagination) do
        locator :xpath => ''
      end
    end
  }


  context "page_object" do
    subject { page_object }
    it { should be_a(PageObject)}
    specify {page_object.class.pages.should include(subject)}

    describe "page_object label" do
      it_should_behave_like "a label"
    end

    describe "page_object locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a String }
    end

    describe "page_object uniq_element" do
      its(:uniq_element_type) { should eq :h1 }
      its(:uniq_element_hash) { should == {:text => 'Testing display of HTML elements'} }
    end

    specify { subject.esets.collect(&:label_value).should include(:test_elements)}
    it { should respond_to(:test_elements) }

    specify { subject.elements.collect(&:label_value).should include(:text_field)}
    it { should respond_to(:text_field) }

    specify { subject.actions.collect(&:label_value).should include(:press_cool_button)}
    it { should respond_to(:fire_press_cool_button) }
  end


  context "elements_set" do
    subject { page_object.esets[page_object.esets.collect(&:label_value).index(:test_elements)] }
    
    it { should be_a(ElementsSet) }

    describe "elements_set label" do
      it_should_behave_like "a label"
    end
  end

  context "element" do
    subject { page_object.elements[page_object.elements.collect(&:label_value).index(:text_field)] }
    
    it { should be_a(Element) }

    describe "element label" do
      it_should_behave_like "a label"
    end
    
    describe "element locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a Hash }
    end

    describe "element food" do
      it { should respond_to(:fresh_food) }
      it { should respond_to(:fresh_food_value) }
      it { should respond_to(:missing_food) }
      it { should respond_to(:missing_food_value) }

      its(:fresh_food_value) { should be_a String}
      its(:missing_food_value) { should be_a String}

      describe "food default values" do
        its(:fresh_food_value){ should eq('undefined fresh food') }
      end

      describe "food user defined values" do
        its(:missing_food_value){ should eq('some missing food') }
      end
    end
  end
    
  context "action" do
    subject { page_object.actions[page_object.actions.collect(&:label_value).index(:press_cool_button)] }

    it { should be_a(Action) }

    describe "action label" do
      it_should_behave_like "a label"
    end

    describe "action next_page" do
      it { should respond_to(:next_page) }
      it { should respond_to(:next_page_value) }
      it { should respond_to(:fire) }

      its(:next_page_value){ should eq(:test_page_with_table) }
      its(:fire) { should be_a Proc }
    end
  end

  context "table" do
    subject { page_object.tables[page_object.tables.collect(&:label_value).index(:table_without_header)] }

    it { should be_a(Table) }

    describe "table label" do
      it_should_behave_like "a label"
    end
  
    describe "element locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a Hash }
    end

    describe "table header" do
      it { should respond_to(:header) }
      it { should respond_to(:header_value) }

      its(:header_value) { should be_a Array}

      describe "default header" do
        subject { page_object.tables[page_object.tables.collect(&:label_value).index(:table_without_header)] }
        let(:default_header){
          h = []
          100.times {|i| h << 'column_'+i.to_s}
          h
        }
        its(:header_value) { should eq(default_header)}
      end

      describe "user defined header" do
      end
    end
  end

  describe "pagination" do
    subject { page_object.paginations[page_object.paginations.collect(&:label_value).index(:some_pagination)] }

    it { should be_a(Pagination) }

    describe "pagination label" do
      it_should_behave_like "a label"
    end
  
    describe "pagination locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a Hash }
    end
  end
end
