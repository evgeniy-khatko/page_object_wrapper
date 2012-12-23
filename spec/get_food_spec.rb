require 'spec_helper'
describe "getting food specified for element" do
  subject{ PageObjectWrapper.receive_page(:some_test_page) }

  describe "page_object.xxx_fresh_food" do
    it "raises NoMethodError if xxx is not known element" do
      expect{ subject.unknown_fresh_food }.to raise_error(NoMethodError)  
    end      

    it{ should respond_to(:tf_fresh_food) }
    its(:tf_fresh_food){ should eq 'some fresh food' }

    it{ should respond_to(:ta_fresh_food) }
    its(:ta_fresh_food){ should eq 'default fresh food' }
  end

  describe "page_object.xxx_missing_food" do
    it "raises NoMethodError if xxx is not known element" do
      expect{ subject.unknown_fresh_food }.to raise_error(NoMethodError)  
    end      

    it{ should respond_to(:tf_fresh_food) }
    its(:tf_missing_food){ should eq 'some missing food' }

    it{ should respond_to(:ta_fresh_food) }
    its(:ta_missing_food){ should eq 'default missing food' }
  end
end
