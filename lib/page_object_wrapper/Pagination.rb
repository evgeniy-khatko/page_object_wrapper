require 'Dsl'
class Pagination < DslElement

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

  def finds_value
    @finds
  end
end

