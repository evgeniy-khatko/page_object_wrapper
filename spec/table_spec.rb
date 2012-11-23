# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "table definition" do
	before :all do
		PageObjectWrapper.domain = 'http://wiki.openqa.org'
	end
	let(:page_object){
		class WatirPage < PageObjectWrapper::Page
			attr_accessor :some_table
			@url="/display/WTR/HTML+Elements+Supported+by+Watir"
			expected_element :a, :text => 'HTML Elements Supported by Watir'
			def initialize visit=false 
				super visit
				@some_table = table(:class => 'confluenceTable')
			end
		end
		WatirPage
	}

	it "has #table(how_find_hash) method to define a table on the page" do
		page = page_object.new(true)
		page.some_table.should be_a(Table)
	end
end
describe "table usage" do
	before :all do
		PageObjectWrapper.domain = 'http://wiki.openqa.org'
	end
	let(:page_object){
		class WatirPage < PageObjectWrapper::Page
			attr_accessor :some_table
			@url="/display/WTR/HTML+Elements+Supported+by+Watir"
			expected_element :a, :text => 'HTML Elements Supported by Watir'
			def initialize visit=false 
				super visit
				@some_table = table(:class => 'confluenceTable')
			end
		end
		WatirPage
	}

	it "has #cells method which returns all Watir table cells" do
		page = page_object.new(true)
		page.some_table.cells.first.should be_a(Watir::TableCell)
	end
	
	it "has #has_cell?(text) method wich returns true if the table has a cell with specified text" do
		page = page_object.new(true)
		page.some_table.should have_cell('<td>')
	end

	it "has #select(column_name, where_hash) method wich returns cell inside specified column wich corresponds to a specified where_hash" do
		page = page_object.new(true)
		cell = page.some_table.select('HTML tag', :where => {'Watir method' => 'cell'})
		cell.should be_a(Watir::TableCell)
		cell.text.should eq '<td>'
	end

	it "is possible to specify just parts of column names in #select method" do
		page = page_object.new(true)
		cell = page.some_table.select('HTML', :where => {'Watir met' => 'cell'})
		cell.should be_a(Watir::TableCell)
		cell.text.should eq '<td>'
	end
end

