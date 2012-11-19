require 'watir-webdriver'
require 'Exceptions.rb'

class Table < Watir::Table
	def initialize(accessor,*args)
		super(accessor, extract_selector(args).merge(:tag_name => "table"))
		@cells=[]
		self.rows.each{|row|
			row.cells.each{|cell|
				@cells << cell
			}
		}
	end

	def has_cell?(text)
		@cells.collect(&:text).include?(text)
	end
	def cells
		@cells
	end
	def select(column_name,where_hash)
		######## TABLE ##############
		# HEADER r0,c0 r0,c1,...,r0cN
		# ROW    r1,c0,r1,c1,...,r1cN
		return_column,find_by_column_name,find_by_column_value=nil
		begin
			return_column=Regexp.new(column_name)
			find_by_column_name=Regexp.new(where_hash[:where].keys.first)
			find_by_column_value=where_hash[:where].values.first
		rescue
			raise TableError.new('invalid parameters, check column names and parameters (must be Table#select(column_name_regexp,:where=>{column_name_regexp=>value_or_:any}))','select',column_name,where_hash) if not find_attrs_valid?(column_name,where_hash)
		end
		index=0
		return_index=nil
		find_by_index=nil
		self.rows[0].cells.each{|header_cell|
			return_index=index if return_column===header_cell.text
			find_by_index=index if find_by_column_name===header_cell.text
			index+=1
		}
		raise TableError.new("column not found",'select',column_name) if return_index.nil?
		raise TableError.new("column not found",'select',where_hash) if find_by_index.nil?
		return self.rows[1].cells[return_index] if find_by_column_value==:any
		found=nil
		self.rows.each{|row|
			found=row.cells[return_index] if row.cells[find_by_index].text==find_by_column_value
		}
		raise TableError.new("value #{find_by_column_value} not found in column #{find_by_column_name}",'select',column_name,where_hash) if found.nil?
		found
	end
end
