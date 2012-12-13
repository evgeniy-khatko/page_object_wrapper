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
class Dsl
  dsl_attr_accessor :label

  def initialize label
    @label = label
  end
protected
  def to_tree(*args)
    args.collect(&:label_value).join(" -> ")
  end
end