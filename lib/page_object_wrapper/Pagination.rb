require 'Dsl'
module PageObjectWrapper
  class Pagination < DslElement

    def initialize(label)
      super label
      @locator = nil
      @finds = nil
      @menu = Hash.new
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
end
