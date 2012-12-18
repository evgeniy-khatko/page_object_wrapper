require 'Dsl'
class Action < DslElement
  attr_reader :fire_block_value, :next_page_value

  def initialize(label, next_page, &block)
    super label
    @next_page_value = next_page
    @fire_block_value = block
  end
end

