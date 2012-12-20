require 'spec_helper'
require 'shared_examples'

describe "page_object.xxx" do
  context "page is opened in browser" do

    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }

    subject{ PageObjectWrapper.open_page(:some_test_page) }

    context "xxx is an element" do
      its(:tf){ should be_a(Watir::TextField) }
      its("tf.id"){ should eq 'f1' }

      its(:ta){ should be_a(Watir::TextArea) }
      its("ta.id"){ should eq 'f2' }

      its(:s1){ should be_a(Watir::Select) }
      its("s1.id"){ should eq 'f10' }

      its(:s2){ should be_a(Watir::Select) }
      its("s2.id"){ should eq 'f11' }

      its(:cb){ should be_a(Watir::CheckBox) }
      its("cb.id"){ should eq 'f5' }

      its(:rb){ should be_a(Watir::Radio) }
      its("rb.id"){ should eq 'f3' }
    end

    context "xxx is an elements_set" do
      its(:test_elements){ should be_a Array }
    end

    context "xxx is not defined in page_object" do
      it "raises NoMethodError" do
        expect{subject.undefined_element}.to raise_error(NoMethodError)
      end
    end
  end

  context "page is not opened in a browser" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
      begin
        PageObjectWrapper.load('./good_pages')
      rescue
      end
    }
    after(:all){ PageObjectWrapper.browser.close }

    subject{ PageObjectWrapper.receive_page(:some_test_page) }
    
    context "xxx is an element" do
      its("tf.present?"){ should be_false }

      it "raises Watir::Exception::UnknownObjectException when working with element" do
        expect{ subject.tf.set 'qqq' }.to raise_error(Watir::Exception::UnknownObjectException)
      end
    end

    context "xxx is an elements_set" do
      its(:test_elements){ should be_a Array }
    end
  end
end


