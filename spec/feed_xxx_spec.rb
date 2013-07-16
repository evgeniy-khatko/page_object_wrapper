require 'spec_helper'
require 'shared_examples'

describe "page_object.feed_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.feed_test_elements }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end

  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new :chrome
      PageObjectWrapper.use_browser @b
    }
    before(:each){ @tp = PageObjectWrapper.open_page(:some_test_page) }
    after(:all){ PageObjectWrapper.browser.quit }
    
    context "xxx not found among current_page element_sets" do
      it "raises NoMethodError" do
        expect{@tp.feed_unknown_elements_set}.to raise_error(NoMethodError)
      end
    end

    it "returns current page object" do
      @tp.feed_tf_standalone(:quite).should be_a Array
      @tp.feed_test_elements(:quite).should be_a Array
      @tp.feed_all(:quite).should be_a Array
    end

    describe "feed_standalone_element" do 
      it "does nothing if menu not spesified" do
        @tp.feed_tf_standalone
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
      end

      it "does nothing if element does not support :select or :set methods" do
        @tp.feed_standalone_cool_button(:loud)
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f3').should_not be_set
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f5').should_not be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f10').value.should eq 'two (default)'
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end

      it "FEEDS elements which has provided menu" do
        @tp.feed_tf_standalone(:loud)
        @b.text_field(:id => 'f1').value.should eq 'tf food'
      end    

      it "FEEDS text_field with String value" do
        @tp.feed_tf_standalone("whible")
        @b.text_field(:id => 'f1').value.should eq 'whible'
      end    

      it "FEEDS checkbox with true value" do
        @tp.feed_cb1(true)
        @b.checkbox(:id => 'f5').should be_set
      end    

      it "FEEDS radio with true" do
        @tp.feed_rb1(true)
        @b.radio(:id => 'f3').should be_set
      end    

      it "FEEDS select list if provided value exists in it" do
        @tp.feed_s1("whible")
        @b.select(:id => 'f10').value.should eq "two (default)"
        @tp.feed_s1("one")
        @b.select(:id => 'f10').value.should eq "one"
      end    

      it "feeds ONLY elements which has provided menu" do
        @tp.feed_tf_standalone(:quite)
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end    

      it "overrides defined menu when passing arguments" do
        @tp.feed_tf_standalone(:loud, :tf_standalone => 'cheef menu')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
      end

      it "can be used without providing a menu" do
        @tp.feed_tf_standalone(:tf_standalone => 'cheef menu')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
      end
    end

    describe "feed_elements_set" do 
      it "does nothing if menu not spesified" do
        @tp.feed_test_elements
        @tp.feed_all
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f3').should_not be_set
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f5').should_not be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f10').value.should eq 'two (default)'
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end

      it "FEEDS elements which has provided menu" do
        @tp.feed_test_elements(:loud)
        @b.text_field(:id => 'f1').value.should eq 'tf food'
        @b.textarea(:id => 'f2').value.should eq "ta food"
        @b.radio(:id => 'f3').should be_set
        @b.radio(:id => 'f4').should_not be_set
        @b.checkbox(:id => 'f5').should be_set
        @b.checkbox(:id => 'f6').should_not be_set
        @b.select(:id => 'f10').value.should eq 'one'
        @b.select(:id => 'f11').value.should eq 'one'
      end    

      it "feeds ONLY elements which has provided menu" do
        @tp.feed_test_elements(:quite)
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end    

      it "overrides defined menu when passing arguments" do
        @tp.feed_test_elements(:loud, :tf => 'cheef menu', :rb1 => false, :rb2 => true, :cb2 => true, :s2 => 'three')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'three'
      end

      it "can be used without providing a menu" do
        @tp.feed_test_elements(:tf => 'cheef menu', :rb2 => true, :cb2 => true, :s2 => 'three')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'three'
      end
    end

    describe "feed_all" do 
      it "does nothing if menu not spesified" do
        @tp.feed_all
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f3').should_not be_set
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f5').should_not be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f10').value.should eq 'two (default)'
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end

      it "FEEDS elements which has provided menu" do
        @tp.feed_all(:loud)
        @b.text_field(:id => 'f1').value.should eq 'tf food'
        @b.textarea(:id => 'f2').value.should eq "ta food"
        @b.radio(:id => 'f3').should be_set
        @b.radio(:id => 'f4').should_not be_set
        @b.checkbox(:id => 'f5').should be_set
        @b.checkbox(:id => 'f6').should_not be_set
        @b.select(:id => 'f10').value.should eq 'one'
        @b.select(:id => 'f11').value.should eq 'one'
      end    

      it "feeds ONLY elements which has provided menu" do
        @tp.feed_all(:quite)
        @b.text_field(:id => 'f1').value.should eq 'Default text.'
        @b.textarea(:id => 'f2').value.should eq "Default text.\n"
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'two (default)'
      end    

      it "overrides defined menu when passing arguments" do
        @tp.feed_all(:loud, :tf => 'cheef menu', :rb1 => false, :rb2 => true, :cb2 => true, :s2 => 'three')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'three'
      end

      it "can be used without providing a menu" do
        @tp.feed_all(:tf => 'cheef menu', :rb2 => true, :cb2 => true, :s2 => 'three')
        @b.text_field(:id => 'f1').value.should eq 'cheef menu'
        @b.radio(:id => 'f4').should be_set
        @b.checkbox(:id => 'f6').should be_set
        @b.select(:id => 'f11').value.should eq 'three'
      end
    end
  end
end
