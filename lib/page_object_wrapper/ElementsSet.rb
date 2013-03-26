pwd = File.dirname(__FILE__) + '/'
require pwd + 'Dsl'
require pwd + 'known_elements'
module PageObjectWrapper
  class ElementsSet < DslElement

    def initialize(label)
      super label
      @elements = []
    end

    KNOWN_ELEMENTS.each{|m|
      ElementsSet.send :define_method, m do |label, &block|
        e = Element.new(label, m.to_sym)
        e.instance_eval(&block)
        @elements << e
      end
    }

    def elements
      @elements
    end
  end
end
