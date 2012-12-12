class PageObject
  attr_accessor :label, :locator, :uniq_element, :elements_set, :elements, :actions, :tables, :paginations
  
  def initialize(label)
    @label = label
    @locator = locator
    @uniq_element = nil
    @elements_set = []
    @elements = []
    @actions = []
    @tables = []
    @paginations = []
  end
end
