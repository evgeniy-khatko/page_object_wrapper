class Class
  def dsl_attr_accessor(*args)
    # iterate through each passed in argument...
    args.each do |arg|
      # getter
      self.class_eval("def #{arg}_value;@#{arg};end")
      # setter
      self.class_eval("def #{arg} val;@#{arg}=val;end")
    end
  end
end
module PageObjectWrapper
  class DslElement
    dsl_attr_accessor :label

    def initialize label
      @label = label
      @label_aliases = []
    end

    def label_alias la
      @label_aliases << la
    end

    def label_alias_value
      @label_aliases
    end

  protected
    def to_tree(*args)
      args.collect(&:label_value).join(" -> ")
    end

    def validate_label

    end
  end

  class DslElementWithLocator < DslElement
    dsl_attr_accessor :locator

    def initialize label
      super label
      @locator = nil
    end
  end
end
