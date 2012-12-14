require 'Dsl'
class Element < Dsl
  dsl_attr_accessor :locator, :fresh_food, :missing_food

  DEFAULT_FRESH_FOOD = 'undefined fresh food'
  DEFAULT_MISSING_FOOD = 'undefined missing food'

  def initialize(label)
    super label
    @locator = nil
    @fresh_food = DEFAULT_FRESH_FOOD
    @missing_food = DEFAULT_MISSING_FOOD
  end
end
