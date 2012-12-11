require 'Editable'
require 'Exceptions'
require 'Submitter'
class Form < Watir::Form
	def initialize(current_page,target_page,accessor,*args)
		super(accessor,extract_selector(args).merge(:tag_name => "form"))
		@elements=[]
		@accessor=accessor
		@current_page=current_page
		@target_page=target_page
		@submit_element = nil
	end

	def editable(type,how_find_hash,label=type,default='Field data',required=false)
		watir_element = @accessor.send(type.to_sym,how_find_hash)
		raise FormError.new('Element not found', 'editable', "TYPE=#{type.inspect}, HOW_FIND=#{how_find_hash.inspect}, PAGE=#{@current_page.class.name}") if not element.exists?
		Form.send :define_method, label do
			watir_element
		end
		@elements << Editable.new(watir_element,label,default,required)
	end

	def submitter(type,how_find_hash,how_click_method ='click',*click_params)
		# find submitter
		@submit_element = Submitter.new(how_click_method,click_params)
		@submit_element.watir_element = @accessor.send(type.to_sym,how_find_hash)
		raise FormError.new('Element not found', 'submitter', "TYPE=#{type.inspect}, HOW_FIND=#{how_find_hash.inspect}") if not @submit_element.watir_element.exists?
	end

	def submit(correct_submission_flag)
		return_page = (correct_submission_flag==true)? @target_page : @current_page
		if @submit_element.nil?
			# submitter is not defined, applying regular form submission
			super()
			return return_page.new
		else
			# submitter defined, applying its submission method
			begin
				@submit_element.watir_element.send(@submit_element.how_click_method.to_sym,*@submit_element.click_params)
			rescue Exception => e
				puts "ORIGINAL ERROR: #{e.message}"
				raise FormError.new('Error clicking submitter', "SUBMITTER: WATIR_ELEMENT=#{@submit_element.watir_element}", "CLICK_METHOD: #{@submit_element.how_click_mehtod}, CLICK_PARAMS: #{@submit_element.click_params}")
			end
			return return_page.new
		end
	end

	def default(label)
		find_input(label).default
	end

	def each
		@elements.each{|e|
			yield e
		}
	end

	def each_required
		@elements.select{|f| f.required}.each{|e|
			yield e
		}
	end

	def fill_only(data_hash)
		if data_hash.nil?
			raise FormError.new('Invalid parameter','fill_only',data_hash)
		else
			data_hash.each_key{|label|
				f=find_input(label)
				f.watir_element.set(data_hash[label])
			}
		end
		self
	end

	def fill_all(except_hash=nil)
		fill_elements(@elements,except_hash)
		self
	end

	def fill_required(except_hash=nil)
		fill_elements(@elements.select{|f| f.required},except_hash)
		self
	end


private
	def find_input(label)
		label = label.to_sym
		index=@elements.collect(&:label).index(label)
		raise FormError.new('label not found','find_input',label) if index.nil?
		@elements[index]
	end
	def fill_elements(elements,except_hash)
		elements = @elements.clone
		if not except_hash.nil?
			if not except_hash.has_key?(:except)
				raise FormError.new('Invalid parameter, must be :except=>"label or [label1,label2,...]"',"fill_elements",elements.inspect,except_hash.inspect)
			else
				if except_hash[:except].is_a?(String) or except_hash[:except].is_a?(Symbol)
					elements.delete(find_input(except_hash[:except]))
				elsif except_hash[:except].is_a?(Array)
					except_hash[:except].each{|label|
						elements.delete(find_input(label))
					}
				else
					raise FormError.new('Invalid parameter',"fill_elements",elements.inspect,except_hash.inspect)
				end
			end
		end
		elements.select{|e| e.respond_to?(:set)}.each{|field|
			field.watir_element.when_present.set(field.default)
		}
	end
end

