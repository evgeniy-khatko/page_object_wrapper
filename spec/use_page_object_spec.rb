require 'spec_helper'
require 'shared_examples'

describe "usage of created pages" do
  before(:all){
    @b = Watir::Browser.new
    PageObjectWrapper.use_browser @b
    PageObjectWrapper.load(File.dirname(__FILE__)+'/../good_pages')
  }
  after(:all){PageObjectWrapper.browser.close}

  describe "page_object.feed_xxx" do

    it "returns current page object" do
      tp = PageObjectWrapper.open_page(:some_test_page)
      tp.feed_test_elements.should eq(tp)
    end

    context "argument = :fresh_food" do
      it "populates all xxx elements with :fresh_food" do
        tp = PageObjectWrapper.current_page
        tp.feed_test_elements(:fresh_food)
        @b.text_field(:id=>'f1').value.should eq 'some fresh food'
        @b.textarea(:id=>'f2').value.should eq 'default fresh food'
        @b.select(:id=>'f10').value.should eq "one\n"
        @b.select(:id=>'f11').value.should eq "one\n"
        @b.checkbox(:id=>'f5').should be_set
        @b.radio(:id=>'f3').should be_set
      end
    end

    context "argument = nil" do
      it "populates all xxx elements with :fresh_food" do
        tp = PageObjectWrapper.current_page
        tp.feed_test_elements
        @b.text_field(:id=>'f1').value.should eq 'some fresh food'
        @b.textarea(:id=>'f2').value.should eq 'default fresh food'
        @b.select(:id=>'f10').value.should eq "one\n"
        @b.select(:id=>'f11').value.should eq "one\n"
        @b.checkbox(:id=>'f5').should be_set
        @b.radio(:id=>'f3').should be_set
      end
    end

    context "argument = :missing_food" do
      it "populates all xxx elements with :missing_food" do
        tp = PageObjectWrapper.open_page(:some_test_page)
        tp.feed_test_elements(:missing_food)
        @b.text_field(:id=>'f1').value.should eq 'some missing food'
        @b.textarea(:id=>'f2').value.should eq 'default missing food'
        @b.select(:id=>'f10').value.should eq "three\n"
        @b.select(:id=>'f11').value.should eq "two (default)\n"
        @b.checkbox(:id=>'f5').should be_set
        @b.radio(:id=>'f3').should be_set
      end
    end

    context "fresh food is not found in select list" do
      it "raises Watir Watir::Exception::NoValueFoundException" do
        atp = PageObjectWrapper.open_page(:another_test_page)
        expect{atp.feed_test_elements}.to raise_error(Watir::Exception::NoValueFoundException)
      end
    end
    context "missing food is not found in select list" do
      it "continues execution" do
        atp = PageObjectWrapper.current_page
        atp.feed_test_elements(:missing_food).should eq(atp)
      end
    end

  end
end
