require 'spec_helper'
require 'shared_examples'

describe "page_object.select_from_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.select_from_table_without_header(:column_1, {:column_2 => ''}) }.to raise_error(PageObjectWrapper::BrowserNotFound)
    end
  end
  context "browser is opened" do
    before(:all){
      @b = Watir::Browser.new
      PageObjectWrapper.use_browser @b
    }
    after(:all){ PageObjectWrapper.browser.quit }
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
        expect{ tp.select_from_table_without_header(:column_1, { :nonexistent_column => 'some value' }) }.to raise_error ArgumentError, ":nonexistent_column not in table header and not == :row"
      end
      it "raises ArgumentError if second_arg's value not meaningful a String or Regexp or Integer" do
        expect{ tp.select_from_table_without_header(:column_1, { :column_2 => Array.new }) }.to raise_error ArgumentError, "[] not a String or Regexp or Integer"
      end
      it "raises ArgumentError if second_arg's key is :row and second_arg's value not Integer" do
        expect{ tp.select_from_table_without_header(:column_1, { :row => "a string" }) }.to raise_error ArgumentError, "\"a string\" not Integer"
      end
      it "raises Watir::Exception::UnknownObjectException if requested for non existing column" do
        expect{ tp.select_from_table_without_header(:column_3).text }.to raise_error(Watir::Exception::UnknownObjectException)
      end
      
      context "next_page specified" do
        it "raises ArgumentError if next_page not symbol" do
          expect{ tp.select_from_table_without_header(:column_1, nil, 'a string') }.to raise_error ArgumentError, '"a string" not a Symbol'
          expect{ tp.select_from_table_without_header(:column_1, {:column_1 => 'Ireland'}, 'a string') }.to raise_error ArgumentError, '"a string" not a Symbol'
        end
        it "raises ArgumentError if next_page not loaded" do
          expect{ tp.select_from_table_without_header(:column_1, nil, :nonexistent_page) }.to raise_error ArgumentError, ':nonexistent_page not known Page'
          expect{ tp.select_from_table_without_header(:column_1, {:column_1 => 'Ireland'}, :nonexistent_page) }.to raise_error ArgumentError, ':nonexistent_page not known Page'
        end
      end
    end

    context "where == nil" do
      context "next_page not specified" do
        it "returns last row value from provided column" do
          tp.select_from_table_without_header(:column_0).text.should eq 'Iceland'
          tp.select_from_table_without_header(:column_1).text.should eq '103,000'
          tp.select_from_table_without_header(:column_2).text.should eq '100,250'
        end
      end
      context "next_page specified" do
        it "returns last row value from provided column" do
          tp.select_from_table_without_header(:column_0, nil, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
        end
      end
    end
    
    context "where not nil" do
      context "next_page not specified" do
        context "found by String" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, :column_1 => '103,000').text.should eq 'Iceland'
            tp.select_from_table_with_header(:country, :total_area => '337,030').text.should eq 'Finland'
          end
          it "returns nil" do
            tp.select_from_table_without_header(:column_0, :column_1 => '123').should eq nil
            tp.select_from_table_with_header(:country, :total_area => '123').should eq nil
          end
        end
        context "found by Regexp" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, :column_1 => /103/).text.should eq 'Iceland'
            tp.select_from_table_with_header(:country, :total_area => /337/).text.should eq 'Finland'
          end
          it "returns nil" do
            tp.select_from_table_without_header(:column_0, :column_1 => /123/).should eq nil
            tp.select_from_table_with_header(:country, :total_area => /123/).should eq nil
          end
        end
        context "found by row number" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, :row => 2).text.should eq 'Iceland'
            tp.select_from_table_with_header(:country, :row => 3).text.should eq 'Norway'
          end
          it "returns nil" do
            tp.select_from_table_with_header(:country, :row => 123).should eq nil
          end
        end
      end
      context "next_page specified" do
        context "found by String" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, {:column_1 => '103,000'}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
          end
          it "returns nil" do
            tp.select_from_table_without_header(:column_0, {:column_1 => '123'}, :some_test_page).should eq nil
          end
        end
        context "found by Regexp" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, {:column_1 => /103/}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
          end
          it "returns nil" do
            tp.select_from_table_without_header(:column_0, {:column_1 => /123/}, :some_test_page).should eq nil
          end
        end
        context "found by row number" do
          it "returns found cells" do
            tp.select_from_table_without_header(:column_0, {:row => 2}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
            tp.select_from_table_with_header(:country, {:row => 3}, :some_test_page).should eq PageObjectWrapper.receive_page(:some_test_page)
          end
          it "returns nil" do
            tp.select_from_table_with_header(:country, {:row => 123}, :some_test_page).should eq nil
          end
        end
      end
    end
  end
end

