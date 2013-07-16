require 'spec_helper'

shared_examples_for "a label" do 
  it { should respond_to(:label)}
  it { should respond_to(:label_value)}
  specify { subject.label_value.should be_a(Symbol)}
end

shared_examples_for "a label alias" do 
  it { should respond_to(:label_alias)}
  it { should respond_to(:label_alias_value)}
  specify { subject.label_alias_value.should be_a(Array)}
end

shared_examples_for "a locator" do 
  it { should respond_to(:locator) }
  it { should respond_to(:locator_value)}
end
