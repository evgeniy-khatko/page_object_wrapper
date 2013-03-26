pwd = File.dirname(__FILE__) + '/'
require pwd + 'Dsl'
module PageObjectWrapper
  class Action < DslElement
    attr_reader :fire_block_value, :next_page_value

    def initialize(label, next_page=nil, &block)
      super label
      @next_page_value = next_page
      @fire_block_value = block
    end
  end
end
