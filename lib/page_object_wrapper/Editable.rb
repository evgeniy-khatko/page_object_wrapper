class Editable
	attr_accessor :type, :how_find_hash, :label, :default, :required 
	def initialize(type,how_find_hash,label,default,required)
		@type=type
		@how_find_hash=how_find_hash
		@label=label.to_sym
		@default=default
		@required=required
	end
end
