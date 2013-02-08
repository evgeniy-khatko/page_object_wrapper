require 'spec_helper'
describe "getting food specified for element" do
  subject{ PageObjectWrapper.receive_page(:some_test_page) }

  describe "page_object.xxx_menu(:food_type)" do
    it "raises NoMethodError if xxx is not known element" do
      expect{ subject.unknown_menu }.to raise_error(NoMethodError)  
    end      

    it{ should respond_to(:tf_menu) }

    it "tf_menu(:loud)" do
      subject.tf_menu(:loud).should eq 'tf food'
    end
    it "rb1(:quite)" do
      subject.rb1_menu(:quite).should eq "false"
    end
    it "tf_menu(:unknown_menu)" do
      subject.tf_menu(:unknown_food).should eq ''
    end
    it "s2_menu('unknown_food')" do
      subject.tf_menu(:unknown_food).should eq ''
    end
  end
end
