require 'Dsl'
class ElementsSet < Dsl

  def initialize(label)
    super label
    @elements = []
  end

  def element(label, &block)
    e = Element.new(label)
    e.instance_eval(&block)
    @elements << e
  end

  def elements
    @elements
  end
end
