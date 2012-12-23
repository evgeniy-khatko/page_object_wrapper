require 'active_support/inflector'
require 'Dsl'
require 'Exceptions'
include PageObjectWrapper

require 'ElementsSet'
require 'Element'
require 'Action'
require 'Alias'
require 'Validator'
require 'Table'
require 'Pagination'
require 'known_elements'

class PageObject < DslElementWithLocator
  attr_reader :esets, :elements, :actions, :aliases, :validators, :tables, :paginations, :uniq_element_type, :uniq_element_hash
  @@browser = nil
  @@pages = []
  @@current_page = nil

  UNIQ_ELEMENT_WAIT_PERIOD = 10
  FOOD_TYPES = [:missing_food, :fresh_food]
  FEED_ALL = Regexp.new(/^feed_all$/)
  FEED_SET = Regexp.new(/^feed_([\w_]+)$/)
  FIRE_ACTION = Regexp.new(/^fire_([\w_]+)$/)
  SELECT_FROM = Regexp.new(/^select_from_([\w_]+)$/)
  PAGINATION_EACH = Regexp.new(/^([\w_]+)_each$/)
  PAGINATION_OPEN = Regexp.new(/^([\w_]+)_open$/)
  VALIDATE = Regexp.new(/^validate_([\w_]+)$/)
    
  def initialize(label)
    super label
    @uniq_element_type = nil
    @uniq_element_hash = {}
    @esets = []
    @elements = []
    @actions = []
    @aliases = []
    @validators = []
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
        feed_elements(@elements, *args)
      when (FEED_SET.match(method_name) and has_eset?($1))
        # page_object.feed_some_elements_set(:fresh_food)
        eset = eset_for($1)
        feed_elements(eset.elements, *args)
      when (FIRE_ACTION.match(method_name) and has_action?($1))
        # page_object.fire_some_action
        a = action_for($1)
        fire_action(a, *args)
      when (FIRE_ACTION.match(method_name) and has_alias?($1))
        # page_object.fire_some_action
        a = alias_for($1)
        fire_action(a, *args)
      when (VALIDATE.match(method_name) and has_validator?($1))
        # page_object.validate_something
        v = validator_for($1)
        run_validator(v, *args)
      when (SELECT_FROM.match(method_name) and has_table?($1))
        # page_object.select_from_some_table(:header_column, {:column => 'value'})
        table = table_for($1)
        select_from_table(table, *args)
      when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
        # page_object.each_pagination
        pagination = pagination_for($1)
        run_each_subpage(pagination, *args)
      when (PAGINATION_OPEN.match(method_name) and has_pagination?($1))
        # page_object.open_padination(1)
        pagination = pagination_for($1)
        open_subpage(pagination, *args)
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
      when (FIRE_ACTION.match(method_name) and has_alias?($1))
        # page_object.fire_some_action
        true
      when (VALIDATE.match(method_name) and has_action?($1))
        # page_object.validate_xxx
        true
      when (SELECT_FROM.match(method_name) and has_table?($1))
        # page_object.select_from_some_table(:header_column, {:column => 'value'})
        true
      when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
        # page_object.each_pagination
        true
      when (PAGINATION_OPEN.match(method_name) and has_pagination?($1))
        # page_object.open_padination(1)
        true
      else
        super
    end
  end

  def self.open_page label, optional_hash=nil
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil?
    raise PageObjectWrapper::UnknownPageObject, label if not @@pages.collect(&:label_value).include?(label)
    page_object = PageObject.find_page_object(label)
    url = ''
    url += @@domain if page_object.locator_value[0]=='/'
    url += page_object.locator_value
    if not (optional_hash.nil? or optional_hash.empty?)
      optional_hash.each{|k,v|
        raise ArgumentError, "#{k.inspect} not Symbol" if not k.is_a? Symbol
        raise ArgumentError, "#{v.inspect} not meaningful String" if not v.is_a? String or v.empty?
        raise PageObjectWrapper::DynamicUrl, "#{k.inspect} not known parameter" if not url.match(':'+k.to_s)
        url.gsub!(/:#{k.to_s}/, v)
      }
    end
    @@browser.goto url
  end

  def self.map_current_page label
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil?
    raise PageObjectWrapper::UnknownPageObject, label if not @@pages.collect(&:label_value).include?(label)
    page_object = PageObject.find_page_object(label)
    if not page_object.uniq_element_type.nil?
      watir_uniq_element = @@browser.send page_object.uniq_element_type, page_object.uniq_element_hash
      begin
        watir_uniq_element.wait_until_present UNIQ_ELEMENT_WAIT_PERIOD
      rescue Watir::Wait::TimeoutError => e
        raise PageObjectWrapper::UnmappedPageObject, "#{label} <=> #{@@browser.url} (#{e.message})" if not watir_uniq_element.present?
      end
    end
    @@current_page = page_object
  end

  def self.current_page
    @@current_page
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
    eset.elements.each{|e|
      PageObject.send :define_method, (e.label_value.to_s+'_fresh_food').to_sym do
        e.fresh_food_value
      end
      PageObject.send :define_method, (e.label_value.to_s+'_missing_food').to_sym do
        e.missing_food_value
      end
    }
    @elements += eset.elements
    eset
  end

  def action(label, next_page, &block)
    a = Action.new(label, next_page, &block)
    @actions << a
    a
  end

  def action_alias(label, next_page, &block)
    a = Alias.new(label, next_page)
    a.instance_eval(&block)
    @aliases << a
    a
  end

  def validator(label, &block)
    v = Validator.new(label, &block)
    @validators << v
    v
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

  def validate
    output = []
    # commented out; already defined pages will e redifined with new definitions
    raise PageObjectWrapper::Load, "\tpage_object #{label_value.inspect} already defined\n" if labeled(@@pages).count(label_value) > 1
    output << "\tlabel #{label_value.inspect} not a Symbol\n" if not label_value.is_a?(Symbol)
    output << "\tlocator #{locator_value.inspect} not a meaningful String\n" if not locator_value.is_a?(String) or locator_value.empty?
    @esets.each{|eset|
      eset_output = []
      eset_output << "\telements_set #{eset.label_value.inspect} already defined\n" if labeled(@esets).count(eset.label_value) > 1
      eset_output << "\tlabel #{eset.label_value.inspect} not a Symbol\n" if not eset.label_value.is_a?(Symbol)
      eset_output.unshift "elements_set(#{eset.label_value.inspect}):\n" if not eset_output.empty?
      output += eset_output
      eset.elements.each{|e|
        element_output = []
        element_output << "\t\telement #{e.label_value.inspect} already defined\n" if labeled(eset.elements).count(e.label_value) > 1
        element_output << "\t\tlabel #{e.label_value.inspect} not a Symbol\n" if not e.label_value.is_a?(Symbol)
        element_output << "\t\tlocator #{e.locator_value.inspect} not a meaningful Hash\n" if not e.locator_value.is_a?(Hash) or e.locator_value.empty?
        element_output.unshift "\telement(#{e.label_value.inspect}):\n" if not element_output.empty?
        output += element_output       
      }
    }
    @actions.each{|a|
      action_output = []
      action_output << "\taction #{a.label_value.inspect} already defined\n" if labeled(@actions).count(a.label_value) > 1
      action_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
      action_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
      action_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not labeled(@@pages).include?(a.next_page_value)
      action_output << "\tfire event is not a Proc\n" if not a.fire_block_value.is_a?(Proc)
      action_output.unshift "action(#{a.label_value.inspect}):\n" if not action_output.empty?
      output += action_output
    }
    @aliases.each{|a|
      alias_output = []
      alias_output << "\talias #{a.label_value.inspect} already defined\n" if labeled(@aliases).count(a.label_value) > 1
      alias_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
      alias_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
      alias_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not labeled(@@pages).include?(a.next_page_value)
      alias_output << "\taction #{a.action_value.inspect} not known Action\n" if not labeled(@actions).include? a.action_value
      alias_output.unshift "alias(#{a.label_value.inspect}):\n" if not alias_output.empty?
      output += alias_output
    }
    @validators.each{|v|
      validator_output = []
      validator_output << "\tvalidator #{v.label_value.inspect} already defined\n" if labeled(@validators).count(v.label_value) > 1
      validator_output << "\tlabel #{v.label_value.inspect} not a Symbol\n" if not v.label_value.is_a?(Symbol)
      validator_output << "\tvalidation block is not a Proc\n" if not v.validate_block_value.is_a?(Proc)
      validator_output.unshift "validator(#{v.label_value.inspect}):\n" if not validator_output.empty?
      output += validator_output
    }
    @tables.each{|t|
      table_output = []
      table_output << "\ttable #{t.label_value.inspect} already defined\n" if labeled(@tables).count(t.label_value) > 1
      table_output << "\tlabel #{t.label_value.inspect} not a Symbol\n" if not t.label_value.is_a?(Symbol)
      table_output << "\tlocator #{t.locator_value.inspect} not a meaningful Hash\n" if not t.locator_value.is_a?(Hash) or t.locator_value.empty?
      table_output << "\theader #{t.header_value.inspect} not a meaningful Array\n" if not t.header_value.is_a?(Array) or t.header_value.empty?
      table_output.unshift "table(#{t.label_value.inspect}):\n" if not table_output.empty?
      output += table_output
    }
    @paginations.each{|p|
      pagination_output = []
      pagination_output << "\tpagination #{p.label_value.inspect} already defined\n" if labeled(@paginations).count(p.label_value) > 1
      pagination_output << "\tlabel #{p.label_value.inspect} not a Symbol\n" if not p.label_value.is_a?(Symbol)
      pagination_output << "\tlocator #{p.locator_value.inspect} not a meaningful Hash\n" if not p.locator_value.is_a?(Hash) or p.locator_value.empty?
      pagination_output.unshift "pagination(#{p.label_value.inspect}):\n" if not pagination_output.empty?
      output += pagination_output
    }
    output.unshift "page_object(#{label_value.inspect}):\n" if not output.empty?
    output
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
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
    food_type ||= :fresh_food
    raise PageObjectWrapper::UnknownFoodType, food_type.inspect if not FOOD_TYPES.include?(food_type)
    elements.each{|e|
      food = e.send (food_type.to_s+'_value').to_sym
      watir_element = @@browser.send e.type, e.locator_value
      case watir_element
        when Watir::CheckBox
          watir_element.when_present.set
        when Watir::Radio
          watir_element.when_present.set
        when Watir::Select
          begin
            watir_element.when_present.select food
          rescue Watir::Exception::NoValueFoundException => e
            if food_type == :missing_food
              # proceed to next element if missing_food is not found in select list
              next
            else
              raise e
            end
          end
        else
          if watir_element.respond_to?(:set)
            watir_element.when_present.set food
          else
            raise PageObjectWrapper::UnableToFeedObject, to_tree(@@current_page, e) + ' check element type'
          end
        end
    }
    self
  end

  def fire_action(a, *args)
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
    block = (a.is_a? Action)? a.fire_block_value : action_for(a.action_value).fire_block_value
    @@browser.instance_exec *args, &block
    self.class.map_current_page a.next_page_value
    @@current_page
  end

  def run_validator(v, *args)
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
    @@browser.instance_exec *args, &v.validate_block_value
  end

  def select_from_table(table, header, *args)
    where = args[0]
    next_page = args[1]
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
    t = @@browser.table(table.locator_value)
    raise ArgumentError, "#{header.inspect} not a Symbol" if not header.is_a? Symbol
    raise ArgumentError, "#{header.inspect} not in table header" if not table.header_value.include? header
    search_for_index = table.header_value.index(header)
    found = nil

    if not next_page.nil?
      raise ArgumentError, "#{next_page.inspect} not a Symbol" if not next_page.is_a? Symbol
      raise ArgumentError, "#{next_page.inspect} not known Page" if not labeled(@@pages).include?(next_page)
    end

    if not where.nil?
      raise ArgumentError, "#{where.inspect} not a meaningful Hash" if not where.is_a? Hash or where.empty?
      raise ArgumentError, "#{where.inspect} has more than 1 keys" if not where.keys.length == 1
      raise ArgumentError, "#{where.keys.first.inspect} not a Symbol" if not where.keys.first.is_a? Symbol
      raise ArgumentError, "#{where.keys.first.inspect} not in table header" if not table.header_value.include? where.keys.first
      raise ArgumentError, "#{where.values.first.inspect} not a String or Regexp" if not (where.values.first.is_a? String or where.values.first.is_a? Regexp)
      search_in_index = table.header_value.index(where.keys.first)
      search_value = where.values.first
      t.rows.each{|r|
        if search_value.is_a? String
          found = r.cells[search_for_index] if r.cells[search_in_index].text == search_value
        elsif search_value.is_a? Regexp
          found = r.cells[search_for_index] if search_value.match(r.cells[search_in_index].text)
        else
          raise ArgumentError, "#{search_value} not a Regexp or String"
        end
      }
    else # where == nil
      found = t.rows.last.cells[search_for_index]
    end

    if not next_page.nil?
      if not found.nil?
        return PageObject.find_page_object(next_page)
      else
        return nil
      end
    else # next_page == nil
      return found
    end
  end

  def each_pagination
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
  end

  def open_padination n
    raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
  end


  def labeled(ary)
    ary.collect(&:label_value)
  end

  [:eset, :element, :table, :pagination, :action, :alias, :validator].each{|el|
    PageObject.send :define_method, 'has_'+el.to_s+'?' do |label| # has_xxx?(label)
      labeled(instance_variable_get("@#{el.to_s.pluralize}")).include?(label.to_sym)
    end
    PageObject.send :define_method, el.to_s+'_for' do |label| # xxx_for(label)
      instance_variable_get("@#{el.to_s.pluralize}")[labeled(instance_variable_get("@#{el.to_s.pluralize}")).index(label.to_sym)]
    end
  }
end
