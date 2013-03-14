require 'Dsl'
class Element < DslElementWithLocator
  attr_reader :type

  def initialize(label, type)
    super label
    @type = type
    @menu = Hash.new
    @press_action = :click
    @required = false
  end

  def menu food_type, value
    @menu[food_type] = value
  end

  def menu_value
    @menu
  end

  def press_action action
    @press_action = action
  end

  def press_action_value
    @press_action
  end

  def required flag
    @required = flag
  end

  def required_value
    @required
  end
end
