pwd = File.dirname(__FILE__) + '/'
require pwd + 'Dsl'
module PageObjectWrapper
  class Table < Element
    attr_reader :type
    dsl_attr_accessor :header
    DEFAULT_HEADER_COLLUMNS_NUMBER = 100 
    DEFAULT_HEADER_COLLUMNS_PREFIX = 'column_'
    

    def initialize(label)
      super label, 'table'
      h = []
      DEFAULT_HEADER_COLLUMNS_NUMBER.times { |i| h << (DEFAULT_HEADER_COLLUMNS_PREFIX+i.to_s).to_sym }
      @header = h
    end
  end
end
