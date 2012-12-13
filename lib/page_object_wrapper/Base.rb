class Dsl
  def dsl_attr_accessor(*args)
    # iterate through each passed in argument...
    args.each do |arg|
      # setter
      self.class_eval("def #{arg} val;@#{arg}=val;end")
      # getter
      self.class_eval("def #{arg}_value;@#{arg};end")
    end
  end
end
