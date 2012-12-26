require 'spec_helper'
describe "getting food specified for element" do
  subject{ PageObjectWrapper.receive_page(:some_test_page) }

  describe "page_object.xxx_menu(:food_type)" do
    it "raises NoMethodError if xxx is not known element" do
      expect{ subject.unknown_menu }.to raise_error(NoMethodError)  
    end      

    it{ should respond_to(:tf_menu) }

    it "tf_menu(:fresh_food)" do
      subject.tf_menu(:fresh_food).should eq 'default fresh food'
    end
    it "tf_menu(:missing_food)" do
      subject.tf_menu(:missing_food).should eq 'default missing food'
    end
    it "tf_menu(:user_defined)" do
      subject.tf_menu(:user_defined).should eq 'some food'
    end
    it "tf_menu(:unknown_food)" do
      subject.tf_menu(:unknown_food).should eq ''
    end
    it "tf_menu('unknown_food')" do
      subject.tf_menu(:unknown_food).should eq ''
    end

  end
end
