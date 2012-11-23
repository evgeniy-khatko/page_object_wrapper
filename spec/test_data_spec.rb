require 'spec_helper'
require 'yaml'

describe "##TestData class" do
	let(:user1){
"login: user1
email: user1@example.com
password: secret1
etc: other data"
	}
	let(:user2){
"login: user2
email: user2@example.com
password: secret2
etc: other data"
	}
	it "is initialized with hash and generates dynamic attributes for an instance" do
		dynamically_defined_user = PageObjectWrapper::TestData.new(YAML.load(user1))
		dynamically_defined_user.login.should eq 'user1'
		dynamically_defined_user.email.should eq 'user1@example.com'
		dynamically_defined_user.password.should eq 'secret1'
		dynamically_defined_user.etc.should eq 'other data'
	end

	it "has .find method which allows finding dynamically defined objects" do
		dynamically_defined_user1 = PageObjectWrapper::TestData.new(YAML.load(user1))
		dynamically_defined_user2 = PageObjectWrapper::TestData.new(YAML.load(user2))
		user1 = PageObjectWrapper::TestData.find(:login,'user1')
		user1.email.should eq 'user1@example.com'
	end
	it "has .each method which allows navigating between objects" do
		dynamically_defined_user1 = PageObjectWrapper::TestData.new(YAML.load(user1))
		dynamically_defined_user2 = PageObjectWrapper::TestData.new(YAML.load(user2))
		user1 = PageObjectWrapper::TestData.each{|user|
			user.etc.should eq 'other data'
		}
	end
end
