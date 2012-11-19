class Submitter
	attr_accessor :how_click_method, :click_params, :watir_element
	def initialize(how_click_method=:click,click_params=nil)
		@how_click_method=how_click_method
		@click_params=click_params
		@watir_element = nil
	end
end
