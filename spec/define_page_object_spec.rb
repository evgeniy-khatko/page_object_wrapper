require 'spec_helper'
require 'shared_examples'

describe "define_page_object" do
  let!(:page_object){
    begin
      PageObjectWrapper.load('./good_pages')
    rescue
    end
    PageObjectWrapper.receive_page(:some_test_page)
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
    it { should respond_to(:feed_test_elements) }

    specify { subject.elements.collect(&:label_value).should include(:tf)}
    it { should respond_to(:tf) }

    specify { subject.actions.collect(&:label_value).should include(:press_cool_button)}
    it { should respond_to(:fire_press_cool_button) }

    specify { subject.tables.collect(&:label_value).should include(:table_without_header)}
    it { should respond_to(:select_from_table_without_header) }
    it { should respond_to(:select_from_table_with_header) }

    specify { subject.paginations.collect(&:label_value).should include(:some_pagination)}
    it { should respond_to(:some_pagination_each) }
    it { should respond_to(:some_pagination_open) }
  end


  context "elements_set" do
    subject { page_object.esets[page_object.esets.collect(&:label_value).index(:test_elements)] }
    
    it { should be_a(ElementsSet) }

    describe "elements_set label" do
      it_should_behave_like "a label"
    end
  end

  context "element" do
    subject { page_object.elements[page_object.elements.collect(&:label_value).index(:tf)] }
    
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
        its(:fresh_food_value){ should eq('some fresh food') }
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
      it { should respond_to(:next_page_value) }
      it { should respond_to(:fire_block_value) }

      its(:next_page_value){ should eq(:test_page_with_table) }
      its(:fire_block_value) { should be_a Proc }
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
          100.times {|i| h << ('column_'+i.to_s).to_sym}
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
