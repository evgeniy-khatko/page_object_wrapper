class Editable
	attr_accessor :watir_element, :label, :default, :required
	def initialize(watir_element,label,default,required)
		@watir_element = watir_element
		@label=label.to_sym
		@default=default
		@required=required
	end

	def required?
		required
	end
end
