require 'Dsl'
class Element < DslElementWithLocator
  attr_reader :type
  dsl_attr_accessor :fresh_food, :missing_food

  DEFAULT_FRESH_FOOD = 'default fresh food'
  DEFAULT_MISSING_FOOD = 'default missing food'

  def initialize(label, type)
    super label
    @type = type
    @fresh_food = DEFAULT_FRESH_FOOD
    @missing_food = DEFAULT_MISSING_FOOD
  end
end
