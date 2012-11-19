class PageError < StandardError 
	attr_accessor :page_url, :page_name
	def initialize(msg,page_name,page_url)
		@page_url=page_url
		@page_name=page_name
		super "PROBLEM: #{(msg.nil?)? '??' : msg}, PAGE: #{page_name}, URL: #{page_url}"
	end

end

class ParameterError < StandardError
	attr_accessor :method, :params
	def initialize(msg,method,*params)
		@method=method
		@params=params
		super "PROBLEM: #{(msg.nil?)? '??' : msg}, METHOD: #{method}, PARAMS: #{params.join('; ').to_s}"
	end
end

class TableError < ParameterError; end
class FormError < ParameterError; end
class DynamicClassError < ParameterError; end
