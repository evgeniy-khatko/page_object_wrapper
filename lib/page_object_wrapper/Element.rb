require 'Dsl'
class Element < DslElementWithLocator
  attr_reader :type

  def initialize(label, type)
    super label
    @type = type
    @menu = Hash.new
  end

  def menu food_type, value
    @menu[food_type] = value
  end

  def menu_value
    @menu
  end
end
