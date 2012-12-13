require 'ElementsSet'
require 'Element'
require 'Action'
require 'Dsl'
require 'Exceptions'
include PageObjectWrapper

class PageObject < Dsl
  attr_accessor :esets, :elements
  dsl_attr_accessor :locator, :uniq_element
  @@browser = nil
  @@pages = []
  @@current_page = nil

  FOOD_TYPES = [:missing_food, :fresh_food]
    
  def initialize(label)
    super label
    @locator = nil
    @uniq_element = nil
    @esets = []
    @elements = []
    @actions = []
    @tables = []
    @paginations = []
  end

  def self.map_current_page label
    raise PageObjectWrapper::UnknownPageObject, label if not @@pages.collect(&:label_value).include?(label)
    page_object = PageObject.find_page_object(label)
    url = ''
    url += @@domain if page_object.locator_value[0]=='/'
    url += page_object.locator_value
    @@browser.goto url
    watir_uniq_element = @@browser.element page_object.uniq_element_value
    puts '!!!!!!!!!!!'
    puts watir_uniq_element
    puts watir_uniq_element.exists?

    raise PageObjectWrapper::UnmappedPageObject, label if not watir_uniq_element.exists?
    @@current_page = page_object
  end

  def self.pages
    @@pages
  end

  def self.browser=(val)
    @@browser = val
  end

  def self.browser
    @@browser
  end

  def elements_set(label, &block)
    eset = ElementsSet.new(label)
    eset.instance_eval(&block)
    @esets << eset
    @elements += eset.elements
    PageObject.send :define_method, label.to_sym do
      eset
    end
    PageObject.send :define_method, "feed_#{label.to_s}" do |food_type|
      raise PageObjectWrapper::UnknownFoodType if food_type.nil? or not FOOD_TYPES.include?(food_type)
      eset.elements.each{|e|
        food = e.send food_type
        watir_element = @@browser.element e.locator
        case watir_element.to_subtype
          when Watir::CheckBox
            watir_element.set
          when Watir::Radio
            watir_element.set
          when Watir::Select
            watir_element.select food
          else
            if watir_element.respond_to?(:set)
              watir_element.set food
            else
              raise PageObjectWrapper::UnableToFeedObject, to_tree(@@current_page, eset, e)
            end
          end
      }
    end
    eset.elements.each{|e|
      PageObject.send :define_method, e.label_value do
        e
      end
    }
    eset
  end

  def action(label, &block)
    a = Action.new(label)
    a.instance_eval(&block)
    @actions << a
    PageObject.send :define_method, "fire_#{label.to_s}" do
      @@browser.instance_eval(a.fire_block)
      find_page_object(a.next_page)
    end
  end

private

  def self.find_page_object(l)
    @@pages.select{|p| p.label_value == l}.first
  end

end
