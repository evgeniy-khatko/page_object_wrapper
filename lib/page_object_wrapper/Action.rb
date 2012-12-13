require 'Dsl'
class Action < Dsl
  attr_reader :fire_block
  dsl_attr_accessor :next_page

  def initialize(label)
    super label
    @fire_block = nil
  end

  def fire(&block)
    @fire_block = proc{block}
  end
end

