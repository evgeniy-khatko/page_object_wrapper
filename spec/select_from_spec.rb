require 'spec_helper'
require 'shared_examples'

describe "page_object.select_from_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      begin
        PageObjectWrapper.load('./good_pages')
      rescue
      end
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.select_from_table_without_header(:column_1, {:column_2 => ''}) }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end
  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
      begin
        PageObjectWrapper.load('./good_pages')
      rescue
      end
    }
    after(:all){ PageObjectWrapper.browser.close }
    let!(:tp){ PageObjectWrapper.open_page(:some_test_page)}

    context "wrong arguments" do
      it "raises ArgumentError if first_arg not a Symbol" do
        expect{ tp.select_from_table_without_header(nil,{}) }.to raise_error ArgumentError, "nil not a Symbol"
      end
      it "raises ArgumentError if first_arg not included in table_header" do
        expect{ tp.select_from_table_without_header(:nonexistent_column, {}) }.to raise_error ArgumentError, ":nonexistent_column not in table header"
      end
      it "raises ArgumentError if second_arg not a meaningful Hash" do
        expect{ tp.select_from_table_without_header(:column_1, 'a string') }.to raise_error ArgumentError, '"a string" not a meaningful Hash'
      end
      it "raises ArgumentError if second_arg has more than 1 keys" do
        expect{ tp.select_from_table_without_header(:column_1, {:column_1 => 'foo', :column_2 => 'bar'})}.to raise_error ArgumentError, '{:column_1=>"foo", :column_2=>"bar"} has more than 1 keys'
      end
      it "raises ArgumentError if second_arg's key not included in table_header" do
        expect{ tp.select_from_table_without_header(:column_1, { :nonexistent_column => 'some value' }) }.to raise_error ArgumentError, ":nonexistent_column not in table header"
      end
      it "raises ArgumentError if second_arg's value not meaningful a String or Regexp" do
        expect{ tp.select_from_table_without_header(:column_1, { :column_2 => Array.new }) }.to raise_error ArgumentError, "[] not a meaningful String or Regexp"
      end
      it "raises Watir::Exception::UnknownObjectException if requested for non existing column" do
        expect{ tp.select_from_table_without_header(:column_3).text }.to raise_error(Watir::Exception::UnknownObjectException)
      end
    end

    context "where == nil" do
      it "returns last row value from provided column" do
        tp.select_from_table_without_header(:column_0).text.should eq 'Sweden'
        tp.select_from_table_without_header(:column_1).text.should eq '449,964'
        tp.select_from_table_without_header(:column_2).text.should eq '410,928'
      end
    end

    context "where not nil" do
      context "found by String" do
        it "returns found cells" do
          tp.select_from_table_without_header(:column_0, :column_1 => '103,000').text.should eq 'Iceland'
          tp.select_from_table_without_header(:column_1).text.should eq '449,964'
          tp.select_from_table_without_header(:column_2).text.should eq '410,928'
        end
      end
      context "found by Regexp" do
      end
    end
  end
end
