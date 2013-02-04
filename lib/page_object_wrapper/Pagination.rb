require 'Dsl'
class Pagination < DslElement
  attr_reader :locator_value, :finds_value

  def initialize(label)
    super label
    @locator = nil
    @finds = nil
  end

  def locator hash, finds
    @locator = hash
    @finds = finds
  end

  def locator_value
    @locator
  end
end

