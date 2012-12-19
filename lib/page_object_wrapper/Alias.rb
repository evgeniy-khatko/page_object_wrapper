require 'Dsl'
class Alias < DslElement
  attr_reader :next_page_value
  dsl_attr_accessor :action

  def initialize(label, next_page)
    super label
    @next_page_value = next_page
  end
end


