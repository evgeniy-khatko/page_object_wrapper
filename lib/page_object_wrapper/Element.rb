require 'Dsl'
class Element < Dsl
  dsl_attr_accessor :locator, :fresh_food, :missing_food

  DEFAULT_FRESH_FOOD = 'default fresh food'
  DEFAULT_MISSING_FOOD = 'default missing food'

  def initialize(label)
    super label
    @locator = nil
    @fresh_food = DEFAULT_FRESH_FOOD
    @missing_food = DEFAULT_MISSING_FOOD
  end
end
