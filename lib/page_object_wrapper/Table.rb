require 'Dsl'
class Table < DslElementWithLocator
  attr_reader :type
  dsl_attr_accessor :header
  DEFAULT_HEADER_COLLUMNS_NUMBER = 100 
  DEFAULT_HEADER_COLLUMNS_PREFIX = 'column_'
  

  def initialize(label)
    super label
    h = []
    DEFAULT_HEADER_COLLUMNS_NUMBER.times { |i| h << (DEFAULT_HEADER_COLLUMNS_PREFIX+i.to_s).to_sym }
    @header = h
    @type = 'table'
    @menu = Hash.new
  end
end
