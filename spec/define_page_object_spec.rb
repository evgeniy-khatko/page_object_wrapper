require 'spec_helper'
require 'shared_examples'
require File.dirname(__FILE__)+'/../lib/page_object_wrapper/known_elements'

describe "define_page_object" do
  let!(:page_object){
    PageObjectWrapper.receive_page(:some_test_page)
  }

  context "page_object" do
    subject { page_object }
    it { should be_a(PageObjectWrapper::PageObject)}
    specify {page_object.class.pages.should include(subject)}

    describe "page_object label" do
      it_should_behave_like "a label"
    end

    describe "page_object label alias" do
      it_should_behave_like "a label alias"
    end

    describe "page_object locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a String }
    end

    describe "page_object uniq_element" do
      specify { subject.elements.collect(&:label_value).should include(:uniq_h1) }
      let(:uniq_element){ subject.elements[subject.elements.collect(&:label_value).index(:uniq_h1)] }
      specify { uniq_element.required_value.should be_true }
    end

    describe "page_object element" do      
      it "can contain known elements" do
        PageObjectWrapper::KNOWN_ELEMENTS.each{ |known|
          subject.should respond_to known
        }
      end
    end

    specify { subject.esets.collect(&:label_value).should include(:test_elements)}
    it { should respond_to(:test_elements) }
    it { should respond_to(:feed_test_elements) }

    specify { subject.elements.collect(&:label_value).should include(:tf)}
    it { should respond_to(:tf) }
    it { should respond_to(:tf_menu) }
    it { should respond_to(:ta_menu) }

    specify { subject.actions.collect(&:label_value).should include(:press_cool_button)}
    it { should respond_to(:fire_press_cool_button) }

    specify { subject.aliases.collect(&:label_value).should include(:fill_textarea_alias)}
    it { should respond_to(:fire_fill_textarea_alias) }

    specify { subject.tables.collect(&:label_value).should include(:table_without_header)}
    it { should respond_to(:select_from_table_without_header) }
    it { should respond_to(:select_from_table_with_header) }

    specify { subject.paginations.collect(&:label_value).should include(:some_pagination)}
    it { should respond_to(:some_pagination_each) }
    it { should respond_to(:some_pagination_open) }

    specify { subject.elements.collect(&:label_value).should include(:tf_standalone)}
    it { should respond_to(:feed_tf_standalone) }
    it { should respond_to(:press_tf_standalone) }

    specify { subject.elements.collect(&:label_value).should include(:standalone_cool_button)}
    it { should respond_to(:press_standalone_cool_button) }
    it { should respond_to(:feed_standalone_cool_button) }
  end

  context "element outside elements_set" do
    subject { page_object.elements[page_object.elements.collect(&:label_value).index(:tf_standalone)] }
    
    it { should be_a(PageObjectWrapper::Element) }

    describe "element label" do
      it_should_behave_like "a label"
    end

    describe "element label alias" do
      it_should_behave_like "a label alias"
    end
    
    describe "element locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a Hash }
    end

    describe "element menu" do
      it { should respond_to(:menu) }
      it { should respond_to(:menu_value) }

      its(:menu_value) { should be_a Hash}

      describe "user defined menu" do
        its(:menu_value){ should have_key :loud }
        its(:menu_value){ should have_value 'tf food'}
      end
    end
  end

  context "elements_set" do
    subject { page_object.esets[page_object.esets.collect(&:label_value).index(:test_elements)] }
    
    it { should be_a(PageObjectWrapper::ElementsSet) }

    describe "elements_set label" do
      it_should_behave_like "a label"
    end

    describe "elements_set label alias" do
      it_should_behave_like "a label alias"
    end
  end

  context "element inside elements_set" do
    subject { page_object.elements[page_object.elements.collect(&:label_value).index(:tf)] }
    
    it { should be_a(PageObjectWrapper::Element) }

    describe "element label" do
      it_should_behave_like "a label"
    end

    describe "element label alias" do
      it_should_behave_like "a label alias"
    end
    
    describe "element locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a Hash }
    end

    describe "element menu" do
      it { should respond_to(:menu) }
      it { should respond_to(:menu_value) }

      its(:menu_value) { should be_a Hash}

      describe "user defined menu" do
        its(:menu_value){ should have_key :loud }
        its(:menu_value){ should have_value 'tf food'}
      end
    end
  end
    
  context "action" do
    subject { page_object.actions[page_object.actions.collect(&:label_value).index(:press_cool_button)] }

    it { should be_a(PageObjectWrapper::Action) }

    describe "action label" do
      it_should_behave_like "a label"
    end

    describe "action attributes" do
      it { should respond_to(:next_page_value) }
      it { should respond_to(:fire_block_value) }

      its(:next_page_value){ should eq(:test_page_with_table) }
      its(:fire_block_value) { should be_a Proc }
    end
  end

  context "action alias" do
    subject { page_object.aliases[page_object.aliases.collect(&:label_value).index(:fill_textarea_alias)] }

    it { should be_a(PageObjectWrapper::Alias) }

    describe "alias label" do
      it_should_behave_like "a label"
    end

    describe "alias attributes" do
      it { should respond_to(:next_page_value) }
      it { should respond_to(:action_value) }

      its(:next_page_value){ should eq :some_test_page }
      its(:action_value) { should eq :fill_textarea }
    end
  end

  context "validator" do
    subject { page_object.validators[page_object.validators.collect(&:label_value).index(:textarea_value)] }

    it { should be_a(PageObjectWrapper::Validator) }

    describe "validator label" do
      it_should_behave_like "a label"
    end

    describe "validator attributes" do
      it { should respond_to(:validate_block_value) }
      its(:validate_block_value) { should be_a Proc }
    end
  end

  context "table" do
    subject { page_object.tables[page_object.tables.collect(&:label_value).index(:table_without_header)] }

    it { should be_a(PageObjectWrapper::Table) }

    describe "table label" do
      it_should_behave_like "a label"
    end

    describe "table label alias" do
      it_should_behave_like "a label alias"
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

    it { should be_a(PageObjectWrapper::Pagination) }

    describe "pagination label" do
      it_should_behave_like "a label"
    end

    describe "pagination label alias" do
      it_should_behave_like "a label alias"
    end
  
    describe "pagination locator" do
      it_should_behave_like "a locator"
      its(:locator_value) { should be_a String }
    end
  end
end
