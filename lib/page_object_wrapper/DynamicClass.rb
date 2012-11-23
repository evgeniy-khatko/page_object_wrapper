# -*- encoding : utf-8 -*-
require 'Exceptions'
class DynamicClass

	def metaclass
		class << self
			self
		end
	end

	@@objects=[]
	def initialize(xml_hash)
		raise DynamicClassError.new('parameter is not a hash','new',xml_hash) if not xml_hash.is_a?(Hash)
		xml_hash.each_pair {|attr, value|
      metaclass.send :attr_accessor, attr
      send "#{attr}=".to_sym, value
    }
		@@objects << self
	end

	def self.find(attr,value)
		ind=@@objects.collect(&attr.to_sym).index(value)
		@@objects[ind]
	end
	def self.each
		@@objects.each{|object|
			yield object
		}
	end
end

