require 'spec_helper'
require 'shared_examples'

describe "page_object.select_from_xxx" do
  context "browser is closed" do
    it "raises PageObjectWrapper::BrowserNotFound" do
      tp = PageObjectWrapper.receive_page(:some_test_page)
      expect{ tp.select_row_from_table_without_header(:column_2 => '') }.to raise_error(PageObjectWrapper::BrowserNotFound)
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
      context "arguments is not a meaningful Hash" do
        it "raises ArgumentError" do
          expect{ tp.select_row_from_table_without_header('') }.to raise_error(ArgumentError)
          expect{ tp.select_row_from_table_with_header({}) }.to raise_error(ArgumentError)
        end
      end

      context "values inside arguments Hash are not strings or :number != Integer" do
        it "raises ArgumentError" do
          expect{ tp.select_row_from_table_with_header(:country => []) }.to raise_error(ArgumentError)
          expect{ tp.select_row_from_table_with_header(:number => 'string') }.to raise_error(ArgumentError)
        end
      end

      context "specified column not found inside table" do
        it "raises ArgumentError" do
          expect{ tp.select_row_from_table_without_header(:unknown_column => 'some value') }.to raise_error(ArgumentError)
          expect{ tp.select_row_from_table_with_header(:column_1 => 'some value') }.to raise_error(ArgumentError)
          expect{ tp.select_row_from_table_with_header(:unknown_column => 'some value') }.to raise_error(ArgumentError)
        end
      end
    end

    context "table with header" do
      it "returns first found row excluding table header" do
        t_row = tp.select_row_from_table_with_header(:number => 2)
        t_row.should be_a Hash
        t_row[:land_area].text.should eq '42,370'
        t_row = tp.select_row_from_table_with_header(:country => 'Denmark')
        t_row.should be_a Hash
        t_row[:country].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_with_header(:number => 2, :country => 'Denmark')
        t_row.should be_a Hash
        t_row[:country].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_with_header(:checkbox => 'false')
        t_row.should be_a Hash
        t_row[:country].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_with_header(:checkbox => 'true')
        t_row.should be_a Hash
        t_row[:country].text.should eq 'Norway'
      end
    end

    context "table without header" do
      it "returns first found row including table header" do
        t_row = tp.select_row_from_table_without_header(:number => 2)
        t_row.should be_a Hash
        t_row[:column_0].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_without_header(:column_0 => 'Denmark')
        t_row.should be_a Hash
        t_row[:column_0].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_without_header(:column_4 => 'false')
        t_row.should be_a Hash
        t_row[:column_0].text.should eq 'Denmark'
        t_row = tp.select_row_from_table_without_header(:number => 2, :column_0 => 'Denmark')
        t_row.should be_a Hash
        t_row[:column_0].text.should eq 'Denmark'
      end
    end

    context "several rows found" do
      it "returns first found row" do
        table_page = tp.fire_press_cool_button
        t_row = table_page.select_row_from_test_table(:column_1 => 'one')
        t_row.should be_a Hash
        t_row[:column_0].text.should eq 'select1'
      end
    end

    context "no rows found" do
      it "returns nil" do
        t_row = tp.select_row_from_table_with_header(:number => 1, :country => 'Russia')
        t_row.should eq nil
        t_row = tp.select_row_from_table_with_header(:country => 'Russia', :land_area => '100')
        t_row.should eq nil
        t_row = tp.select_row_from_table_without_header(:number => 1, :column_1 => 'Russia')
        t_row.should eq nil
      end
    end
  end
end
