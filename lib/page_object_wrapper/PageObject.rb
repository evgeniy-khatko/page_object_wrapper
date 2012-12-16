require 'Dsl'
require 'Exceptions'
include PageObjectWrapper

require 'ElementsSet'
require 'Element'
require 'Action'
require 'Table'
require 'Pagination'
require 'known_elements'

class PageObject < DslElementWithLocator
  attr_reader :esets, :elements, :actions, :tables, :paginations, :uniq_element_type, :uniq_element_hash
  @@browser = nil
  @@pages = []
  @@current_page = nil

  FOOD_TYPES = [:missing_food, :fresh_food]
  FEED_ALL = Regexp.new(/^feed_all$/)
  FEED_SET = Regexp.new(/^feed_([\w_]+)$/)
  FIRE_ACTION = Regexp.new(/^fire_([\w_]+)$/)
  SELECT_FROM = Regexp.new(/^select_from_([\w_]+)$/)
  PAGINATION_EACH = Regexp.new(/^each_([\w_]+)$/)
  PAGINATION_OPEN = Regexp.new(/^open_([\w_]+)$/)
    
  def initialize(label)
    super label
    @uniq_element_type = 'element'
    @uniq_element_hash = {}
    @esets = []
    @elements = []
    @actions = []
    @tables = []
    @paginations = []
  end

  # lazy evaluated calls of real watir elements are handled by :method_missing
  def method_missing(method_name, *args)
    case 
      when KNOWN_ELEMENTS.include?(method_name.to_s.gsub(/^uniq_/,''))
        # page_object.uniq_xxx(hash)
        @uniq_element_type = method_name.to_s.gsub(/^uniq_/,'').to_sym
        @uniq_element_hash = args[0]
      when has_eset?(method_name)
        # page_object.some_elements_set
        eset = eset_for(method_name)
        return_array_of_watir_elements(eset)
      when has_element?(method_name)
        # page_object.some_element
        element = element_for(method_name)
        return_watir_element(element)
      when FEED_ALL.match(method_name)
        # page_object.feed_all(:fresh_food)
        feed_elements(@elements, args)
      when (FEED_SET.match(method_name) and has_eset?($1))
        # page_object.feed_some_elements_set(:fresh_food)
        eset = eset_for($1)
        feed_elements(eset.elements, args)
      when (FIRE_ACTION.match(method_name) and has_action?($1))
        # page_object.fire_some_action
        a = action_for($1)
        fire_action(a, args)
      when (SELECT_FROM.match(method_name) and has_table?($1))
        # page_object.select_from_some_table(:header_column, {:column => 'value'})
        table = table_for($1)
        select_from_table(table, args)
      when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
        # page_object.each_pagination
        pagination = pagination_for($1)
        run_each_subpage(pagination, args)
      when (PAGINATION_OPEN.match(method_name) and has_paginations?($1))
        # page_object.open_padination(1)
        pagination = pagination_for($1)
        open_subpage(pagination, args)
      else
        super
    end
  end

  # corresponding respond_to? 
  def respond_to?(method_sym, include_private = false)
    method_name = method_sym.to_s
    case 
      when KNOWN_ELEMENTS.include?(method_name.gsub(/^uniq_/,''))
        # page_object.uniq_xxx(hash)
        true
      when has_eset?(method_name)
        # page_object.some_elements_set
        true
      when has_element?(method_name)
        # page_object.some_element
        true
      when FEED_ALL.match(method_name)
        # page_object.feed_all(:fresh_food)
        true
      when (FEED_SET.match(method_name) and has_eset?($1))
        # page_object.feed_some_elements_set(:fresh_food)
        true
      when (FIRE_ACTION.match(method_name) and has_action?($1))
        # page_object.fire_some_action
        true
      when (SELECT_FROM.match(method_name) and has_table?($1))
        # page_object.select_from_some_table(:header_column, {:column => 'value'})
        true
      when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
        # page_object.each_pagination
        true
      when (PAGINATION_OPEN.match(method_name) and has_paginations?($1))
        # page_object.open_padination(1)
        true
      else
        super
    end
  end

  def self.map_current_page label
    raise PageObjectWrapper::UnknownPageObject, label if not @@pages.collect(&:label_value).include?(label)
    page_object = PageObject.find_page_object(label)
    url = ''
    url += @@domain if page_object.locator_value[0]=='/'
    url += page_object.locator_value
    @@browser.goto url
    watir_uniq_element = @@browser.send page_object.uniq_element_type, page_object.uniq_element_hash
    raise PageObjectWrapper::UnmappedPageObject, "#{label} <=> #{@@browser.url}" if not watir_uniq_element.present?
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
    eset
  end

  def action(label, &block)
    a = Action.new(label)
    a.instance_eval(&block)
    @actions << a
    a
  end

  def table(label, &block)
    t = Table.new(label)
    t.instance_eval(&block)
    @tables << t
    t
  end


  def pagination(label, &block)
    p = Pagination.new(label)
    p.instance_eval(&block)
    @paginations << p
    p
  end
private

  def self.find_page_object(l)
    @@pages.select{|p| p.label_value == l}.first
  end
  
  def return_watir_element(e)
    @@browser.send e.type, e.locator_value
  end

  def return_array_of_watir_elements(eset)
    eset.elements.collect{|e| @@browser.send(e.type, e.locator_value)}
  end

  def feed_elements(elements, food_type=nil)
    food_type ||= :fresh_food
    raise PageObjectWrapper::UnknownFoodType if not FOOD_TYPES.include?(food_type)
    elements.each{|e|
      food = e.send (food_type.to_s+'_value').to_sym
      watir_element = @@browser.send e.type, e.locator_value
      case watir_element
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

  def fire_action(a)
  end

  def select_from_table(table, header, where)
  end



  def labeled(ary)
    ary.collect(&:label_value)
  end

  def has_eset?(label)
    labeled(@esets).include?(label.to_sym)
  end

  def has_element?(label)
    labeled(@elements).include?(label.to_sym)
  end
  
  def has_table?(label)
    labeled(@tables).include?(label.to_sym)
  end

  def has_pagination?(label)
    labeled(@paginations).include?(label.to_sym)
  end

  def has_action?(label)
    labeled(@actions).include?(label.to_sym)
  end

  def eset_for(label)
    @esets[labeled(@esets).index(label.to_sym)]
  end

  def element_for(label)
    @elements[labeled(@elements).index(label.to_sym)]
  end

  def table_for(label)
    @tables[labeled(@tables).index(label.to_sym)]
  end

  def pagination_for(label)
    @paginations[labeled(@paginations).index(label.to_sym)]
  end

  def action_for(label)
    @actions[labeled(@actions).index(label.to_sym)]
  end
end
