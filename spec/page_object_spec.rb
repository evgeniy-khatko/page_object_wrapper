require 'spec_helper'
require 'page_object_element_spec'

describe Page do
  context ":label is a symbol, :locator is a page path inside a domain" do
    it_behaves_like PageObjectElement
  end

  describe "public behavior" do
    describe "identifier" do
      let(:page_object){}
      it "is checked for existance when Page is being opened" do
      end
    end

    describe "open" do
      let(:page_object){}
      it "is invoked without arguments" do
      end

      it "navigates browser to the parent Page url (locator)" do
      end
    end

    describe "feed_xxx_elements" do
      let(:page_object){}
      context "xxx is the elements_set :..." do
        it_behaves_like "feed_elements"

        it "does not populate fileds which are not specified in the optional hash" do
        end

        it "is created dynamically depending on Page element_sets defined in the page" do
        end
      end

      context "xxx = all (all page_object elements)" do
        it_behaves_like "feed_elements"

        it "populates fields which are not specified in the optional hash with default data" do
        end
      end
    end

    describe "fire_xxx_action" do
      let(:page_object){}

      it "runs a user defined action" do
      end

      it "returns next page_object" do
      end
    end

    describe "select_from_xxx_table" do
      let(:page_object){}

      it "accepts two arguments - :column_to_select_from, {:column_to_find_in => text_to_find}" do
      end
      
      it "returns the first Watir::TableCell which satisfies the arguments" do
      end
    end
  end
