require 'watir-webdriver'
require 'Editable'
require 'Exceptions'
require 'Submitter'
class Form < Watir::Form
	def initialize(current_page,target_page,accessor,*args)
		super(accessor,extract_selector(args).merge(:tag_name => "form"))
		@inputs=[]
		@accessor=accessor
		@current_page=current_page
		@target_page=target_page
		@submit_element = nil
	end

	def editable(type,how_find_hash,label=type,default='Field data',required=false)
		@inputs << Editable.new(type,how_find_hash,label,default,required)
		Form.send :define_method, label do
			element = @accessor.send(type.to_sym,how_find_hash)
			raise FormError.new('Element not found', 'editable', "TYPE=#{type.inspect}, HOW_FIND=#{how_find_hash.inspect}") if not element.exist?
		end
	end

	def submitter(type,how_find_hash,how_click_method = :click,*click_params)
		# find submitter
		@submit_element = Submitter.new(how_click_method,click_params)
		@submit_element.watir_element = @accessor.send(type.to_sym,how_find_hash)
		raise FormError.new('Element not found', 'submitter', "TYPE=#{type.inspect}, HOW_FIND=#{how_find_hash.inspect}") if not @submit_element.watir_element.exist?
	end

	def submit(correct_submission_flag)
		return_page = (correct_submission_flag==true)? @target_page : @current_page
		if @submit_element.nil?
			# submitter is not defined, applying regular form submission
			super
			return return_page.new
		else
			# submitter defined, applying its submission method
			begin
				@submit_element.watir_element.send(@submit_element.how_click_method.to_sym,*@submit_element.click_params)
			rescue Exception => e
				puts "ORIGINAL ERROR: #{e.message}"
				raise FormError.new('Submitter not clickable', "SUBMITTER: TYPE=#{@submit_element.type}, HOW_FIND=#{@submit_element.how_find_hash}", "CLICK_METHOD: #{@submit_element.how_click_mehtod}, CLICK_PARAMS: #{@submit_element.click_params}")
			end
			return return_page.new
		end
	end

	def fill_only(data_hash)
		if data_hash.nil?
			raise FormError.new('Invalid parameter','fill_only',data_hash)
		else
			data_hash.each_key{|label|
				f=find_input(label)
				@accessor.send(f.type.to_sym,f.how_find_hash).set(data_hash[label])
			}
		end
	end

	def fill_all(except_hash=nil)
		fill_inputs(@inputs,except_hash)
	end

	def fill_required(except_hash=nil)
		fill_inputs(@inputs.select{|f| f.required},except_hash)
	end

	def default(label)
		find_input(label).default
	end


private
	def find_input(label)
		index=@inputs.collect(&:label).index(label)
		raise FormError.new('label not found','find_input',label) if index.nil?
		@inputs[index]
	end
	def fill_inputs(inputs,except_hash)
		if not except_hash.nil?
			if not except_hash.has_key?(:except)
				raise FormError.new('Invalid parameter, must be :except=>"label or [label1,label2,...]"',"fill_inputs",inputs.inspect,except_hash.inspect)
			else
				if except_hash[:except].is_a?(String)
					inputs.delete(find_input(except_hash[:except]))
				elsif except_hash[:except].is_a?(Array)
					except_hash[:except].each{|label|
						inputs.delete(find_input(label))
					}
				else
					raise FormError.new('Invalid parameter',"fill_inputs",inputs.inspect,except_hash.inspect)
				end
			end
		end
		inputs.each{|f|
			real_input=@accessor.send(f.type.to_sym,f.how_find_hash)
			raise FormError.new("input id=#{id} not found","fill_inputs",inputs.inspect,except_hash.inspect) if not real_input.exists?
			real_input.when_present.set(f.default)
		}
	end
end

