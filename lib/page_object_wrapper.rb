# -*- encoding : utf-8 -*-
require "watir-webdriver"
require "version"
require 'Exceptions'
require 'Form'
require 'Table'
require 'Pagination'
require 'DynamicClass'

module PageObjectWrapper

	class TestData < DynamicClass; end

	def self.start_browser b=nil
		Page.accessor = (b.nil?)? Watir::Browser.new : b
		Page.accessor.driver.manage.timeouts.implicit_wait=3
		Page.accessor.driver.manage.timeouts.page_load=30
		Page.accessor.driver.manage.timeouts.script_timeout=30
	end

	def self.stop_browser
		Page.accessor.quit
	end

	def self.restart_browser
		self.stop_browser
		self.start_browser
	end

	def self.domain=(val)
		Page.base_url = val
	end

	class Page
		class << self
			attr_accessor :url, :expected_elements, :full_url
		end

		@@base_url = ''
		@@accessor = nil
		@url = ''
		@expected_elements = {}

		def initialize visit = false
			self.class.full_url = @@base_url + self.class.url
			@@accessor.goto self.class.full_url if visit		

			if not self.class.expected_elements.nil? 
				if not (self.class.expected_elements.empty?)
					self.class.expected_elements.each{|element_type, identifier|
						begin
							@@accessor.send(element_type,identifier).wait_until_present
						rescue
							raise PageError.new("expected_element #{element_type}, #{identifier.inspect} not found after a set timeout",self.class,self.class.full_url)
						end
					}
				end
			end
		end

		def self.base_url=(val)
			@@base_url = val
		end

		def self.base_url
			@@base_url
		end

		def self.accessor
			@@accessor
		end

		def self.accessor=(val)
			@@accessor = val
		end
		def self.expected_element(element_type,identifier)
			self.expected_elements = {} if self.expected_elements.nil?
			self.expected_elements[element_type] = identifier
		end

		def form(target_page,*args)
			Form.new(self.class,target_page,@@accessor,*args)
		end

		def table(*args)
			Table.new(@@accessor,*args)
		end

		def paginate(div_args)
			Pagination.new(self,div_args)
		end

		def has_warning?(text)
			@@accessor.text.include?(text)
		end

		alias :has_text? :has_warning?
	end
end
