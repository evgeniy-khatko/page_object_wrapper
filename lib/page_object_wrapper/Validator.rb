require 'Dsl'
class Validator < DslElement
  attr_reader :validate_block_value

  def initialize(label, &block)
    super label
    @validate_block_value = block
  end
end

