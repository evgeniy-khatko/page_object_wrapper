require 'Dsl'
class Table < DslElementWithLocator
  dsl_attr_accessor :header
  DEFAULT_HEADER_COLLUMNS_NUMBER = 100 
  DEFAULT_HEADER_COLLUMNS_PREFIX = 'column_'
  

  def initialize(label)
    super label
    h = []
    DEFAULT_HEADER_COLLUMNS_NUMBER.times { |i| h << DEFAULT_HEADER_COLLUMNS_PREFIX+i.to_s }
    @header = h
  end
end

