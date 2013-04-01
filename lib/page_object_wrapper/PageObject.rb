require 'active_support/inflector'
pwd = File.dirname(__FILE__)
require pwd + '/Action'
require pwd + '/Dsl'
require pwd + '/Exceptions'
require pwd + '/ElementsSet'
require pwd + '/Element'
require pwd + '/Alias'
require pwd + '/Validator'
require pwd + '/Table'
require pwd + '/Pagination'
require pwd + '/Element'
require pwd + '/known_elements'

module PageObjectWrapper
  class PageObject < DslElementWithLocator
    attr_reader :esets, :elements, :actions, :aliases, :validators, :tables, :paginations, :uniq_element_type, :uniq_element_hash
    @@browser = nil
    @@pages = []
    @@current_page = nil

    REQUIRED_ELEMENT_WAIT_PERIOD = 10
    FEED_ALL = Regexp.new(/^feed_all$/)
    FEED = Regexp.new(/^feed_([\w_]+)$/)
    FIRE_ACTION = Regexp.new(/^fire_([\w_]+)$/)
    SELECT_FROM = Regexp.new(/^select_from_([\w_]+)$/)
    PAGINATION_EACH = Regexp.new(/^([\w_]+)_each$/)
    PAGINATION_OPEN = Regexp.new(/^([\w_]+)_open$/)
    VALIDATE = Regexp.new(/^validate_([\w_\?]+)$/)
    PRESS = Regexp.new(/^press_([\w_\?]+)$/)
      
    def initialize(label)
      super label
      @esets = []
      @elements = []
      @actions = []
      @aliases = []
      @validators = []
      @tables = []
      @paginations = []
    end

    KNOWN_ELEMENTS.each{|m|
      PageObject.send :define_method, m do |l, &b|
        e = Element.new(l, m.to_sym)
        e.instance_eval(&b)
        @elements << e
      end
    }

    # lazy evaluated calls of real watir elements are handled by :method_missing
    def method_missing(method_name, *args, &block)
      case 
        when KNOWN_ELEMENTS.include?(method_name.to_s.gsub(/^uniq_/,''))
          # page_object.uniq_xxx(hash)
          meth = method_name.to_s.gsub(/^uniq_/,'')
          e = Element.new(method_name.to_sym, meth)
          e.instance_eval { locator(args[0]); required(true) }
          @elements << e
        when has_eset?(method_name)
          # page_object.some_elements_set
          eset = eset_for(method_name)
          PageObject.return_array_of_watir_elements(eset)
        when has_element?(method_name)
          # page_object.some_element
          element = element_for(method_name)
          PageObject.return_watir_element element
        when FEED_ALL.match(method_name)
          # page_object.feed_all(:fresh_food)
          feed_elements(@elements, *args)
        when (FEED.match(method_name) and has_eset?($1))
          # page_object.feed_some_elements_set(:fresh_food)
          eset = eset_for($1)
          feed_elements(eset.elements, *args)
        when (FEED.match(method_name) and has_element?($1))
          # page_object.feed_some_element(:fresh_food)
          e = element_for($1)
          if [true, false].include? args[0] or args[0].is_a? String 
            feed_field(e, args[0])
          else
            feed_elements([e], *args)
          end
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
          select_from(table, *args)
        when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
          # page_object.each_pagination
          pagination = pagination_for($1)
          run_each_subpage(pagination, *args, &block)
        when (PAGINATION_OPEN.match(method_name) and has_pagination?($1))
          # page_object.open_padination(1)
          pagination = pagination_for($1)
          open_subpage(pagination, *args)
        when (PRESS.match(method_name) and has_element?($1))
          # page_object.press_element
          element = element_for($1)
          press(element)
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
        when (FEED.match(method_name) and has_eset?($1))
          # page_object.feed_some_elements_set(:fresh_food)
          true
        when (FEED.match(method_name) and has_element?($1))
          # page_object.feed_some_element(:fresh_food)
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
        when (PRESS.match(method_name) and has_element?($1))
          # page_object.press_element
          true
        else
          super
      end
    end

    def self.open_page label, optional_hash=nil
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil?
      raise PageObjectWrapper::UnknownPageObject, label.inspect if not @@pages.collect(&:label_value).include?(label)
      page_object = PageObject.find_page_object(label)
      url = ''
      url += PageObjectWrapper.domain if page_object.locator_value[0]=='/'
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
      raise PageObjectWrapper::UnknownPageObject, label.inspect if not @@pages.collect(&:label_value).include?(label)
      page_object = PageObject.find_page_object(label)
      page_object.elements.select{ |e| e.required_value == true }.each{ |required_element|
        begin
          watir_element = return_watir_element required_element
          watir_element.wait_until_present REQUIRED_ELEMENT_WAIT_PERIOD
        rescue Watir::Wait::TimeoutError => e
          raise PageObjectWrapper::UnmappedPageObject, "#{label} <=> #{@@browser.url} (#{e.message})" if not watir_element.present?
        end
      }
      @@current_page = page_object
    end

    def self.current_page? label
      self.map_current_page label
      true
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
        PageObject.send :define_method, (e.label_value.to_s+'_menu').to_sym do |food_type|
          e.menu_value[food_type].to_s
        end
      }
      @elements += eset.elements
      eset
    end

    def action(label, next_page=nil, &block)
      a = Action.new(label, next_page, &block)
      @actions << a
      a
    end

    def action_alias(label, next_page=nil, &block)
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
      @elements << t
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
      }
      @elements.each{|e|
        element_output = []
        element_output << "\telement #{e.label_value.inspect} already defined\n" if labeled(@elements).count(e.label_value) > 1
        element_output << "\tlabel #{e.label_value.inspect} not a Symbol\n" if not e.label_value.is_a?(Symbol)
        element_output << "\tlocator #{e.locator_value.inspect} not a meaningful Hash or String\n" if (not e.locator_value.is_a?(Hash) and not e.locator_value.is_a?(String)) \
                                                                                                      or e.locator_value.empty?
        element_output << "\tmenu #{e.menu_value.inspect} not properly defined (must be { :food_type => 'a string' | true | false })\n" if (not e.menu_value.empty?) and \
                                                                                                                                          ((e.menu_value.keys.collect(&:class).uniq != [Symbol]) \
                                                                                                                                           or not (e.menu_value.values.collect(&:class).uniq - [String, TrueClass, FalseClass]).empty?)
        element_output << "\trequired flag #{e.required_value.inspect} not a true | false\n" if not [true, false].include? e.required_value
        element_output.unshift "element(#{e.label_value.inspect}):\n" if not element_output.empty?
        output += element_output       
      }
      @actions.each{|a|
        action_output = []
        action_output << "\taction #{a.label_value.inspect} already defined\n" if labeled(@actions).count(a.label_value) > 1
        action_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
        if not a.next_page_value.nil?
          action_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
          action_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not labeled(@@pages).include?(a.next_page_value)
        end
        action_output << "\tfire event is not a Proc\n" if not a.fire_block_value.is_a?(Proc)
        action_output.unshift "action(#{a.label_value.inspect}):\n" if not action_output.empty?
        output += action_output
      }
      @aliases.each{|a|
        alias_output = []
        alias_output << "\talias #{a.label_value.inspect} already defined\n" if labeled(@aliases).count(a.label_value) > 1
        alias_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
        if not a.next_page_value.nil?
          alias_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
          alias_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not labeled(@@pages).include?(a.next_page_value)
        end
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
        table_output << "\theader #{t.header_value.inspect} not a meaningful Array\n" if not t.header_value.is_a?(Array) or t.header_value.empty?
        table_output.unshift "table(#{t.label_value.inspect}):\n" if not table_output.empty?
        output += table_output
      }
      @paginations.each{|p|
        pagination_output = []
        pagination_output << "\tpagination #{p.label_value.inspect} already defined\n" if labeled(@paginations).count(p.label_value) > 1
        pagination_output << "\tlabel #{p.label_value.inspect} not a Symbol\n" if not p.label_value.is_a?(Symbol)
        pagination_output << "\tlocator #{p.locator_value.inspect} not a meaningful String\n" if not p.locator_value.is_a?(String) or p.locator_value.empty?
        pagination_output << "\t\"#{p.finds_value}\" not found in #{p.locator_value}\n" if not p.locator_value =~ /#{p.finds_value.to_s}/
        pagination_output.unshift "pagination(#{p.label_value.inspect}):\n" if not pagination_output.empty?
        output += pagination_output
      }
      output.unshift "page_object(#{label_value.inspect}):\n" if not output.empty?
      output
    end

  private

    def self.find_page_object(l)
      p = @@pages.select{|p| p.label_value == l}.first
      raise ArgumentError, "#{l.inspect} not known Page" if p.nil?
      p
    end
    
    def self.return_watir_element(e)
      el = nil
      if e.locator_value.is_a? Hash
        el = @@browser.send e.type, e.locator_value
      elsif e.locator_value.is_a? String
        el = @@browser.instance_eval e.locator_value
      end
      el
    end

    def self.return_array_of_watir_elements(eset)
      eset.elements.collect{|e| return_watir_element(e)}
    end

    def feed_elements(elements, *args)
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      menu_name, cheef_menu = nil, nil
      
      if args[0].is_a? Symbol
        menu_name = args[0]
        cheef_menu = args[1]
      elsif args[0].is_a? Hash
        cheef_menu = args[0]
      end
      if not cheef_menu.nil?
        raise ArgumentError, "#{cheef_menu.inspect} not meaningful Hash" if not cheef_menu.is_a? Hash or cheef_menu.empty?
      end
      menus = []
      elements.each{ |e| menus += e.menu_value.keys }
      elements.each{|e|
        if not cheef_menu.nil? and cheef_menu.keys.include? e.label_value
          food = cheef_menu[e.label_value]
        else
          food = e.menu_value[menu_name].to_s
        end
        watir_element = PageObject.return_watir_element e
        case watir_element
          when Watir::CheckBox
            watir_element.when_present.set eval(food) if ["true", "false"].include? food
          when Watir::Radio
            watir_element.when_present.set if food=="true"          
          when Watir::Select
            watir_element.select food if watir_element.include? food
          else
            if watir_element.respond_to?(:set)
              watir_element.when_present.set food if food!=''
            else
              # this is an element which does not support input (e.g. button) => skipping it
              next
              #raise PageObjectWrapper::UnableToFeedObject, to_tree(@@current_page, e) + ' check element type'
            end
          end
      }
      self
    end

    def feed_field(e, value)
      watir_element = PageObject.return_watir_element e
      case watir_element
      when Watir::CheckBox
          watir_element.when_present.set value if [true, false].include? value
      when Watir::Radio
          watir_element.when_present.set if value==true          
      when Watir::Select
          watir_element.select value if watir_element.include? value
      else
        if watir_element.respond_to?(:set)
          watir_element.when_present.set value 
        end
      end
    end


    def fire_action(a, *args)
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      block = (a.is_a? Action)? a.fire_block_value : action_for(a.action_value).fire_block_value
      block_result = @@browser.instance_exec *args, &block
      if not a.next_page_value.nil?
        self.class.map_current_page a.next_page_value
        return @@current_page
      else
        return block_result
      end 
    end

    def run_validator(v, *args)
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      @@browser.instance_exec *args, &v.validate_block_value
    end

    def select_from(table, header, *args)
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
        raise ArgumentError, "#{where.keys.first.inspect} not in table header and not == :row" if not ( table.header_value.include? where.keys.first or where.keys.first == :row )
        raise ArgumentError, "#{where.values.first.inspect} not a String or Regexp or Integer" if not ( where.values.first.is_a? String or where.values.first.is_a? Regexp or where.values.first.is_a? Integer)
        search_value = where.values.first
        if where.keys.first == :row # finding by row number
          raise ArgumentError, "#{where.values.first.inspect} not Integer" if not ( where.values.first.is_a? Integer)
          begin 
            found = t.rows[search_value+1].cells[search_for_index] # +1 because we want rows to start from 0 (similar to columns)
          rescue Watir::Exception::UnknownObjectException
            found = nil
          end
        else # finding by String or Regexp
          search_in_index = table.header_value.index(where.keys.first)
          t.rows.each{|r|
            if search_value.is_a? String
              begin 
                found = r.cells[search_for_index] if r.cells[search_in_index].text == search_value
              rescue Watir::Exception::UnknownObjectException
                found = nil
              end
            elsif search_value.is_a? Regexp
              begin
                found = r.cells[search_for_index] if search_value.match(r.cells[search_in_index].text)
              rescue Watir::Exception::UnknownObjectException
                found = nil
              end
            else
              raise ArgumentError, "#{search_value} not a Regexp or String"
            end
          }
        end
      else # where == nil
        begin
          found = t.rows[t.rows.length/2].cells[search_for_index] # returning some "middle" row cell value
        rescue Watir::Exception::UnknownObjectException
          found = nil
        end
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

    def run_each_subpage(p, opts=nil, &block)
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      limit = opts[:limit] if not opts.nil?
      raise PageObjectWrapper::InvalidPagination, opts.inspect if limit < 0 if not limit.nil?

      @@browser.instance_eval "(#{p.locator_value}).wait_until_present)"
      current_link = @@browser.instance_eval p.locator_value
      raise PageObjectWrapper::InvalidPagination, p.locator_value+'; '+p.finds_value if not current_link.present?
      current_page_number = p.finds_value.to_i
      counter = 0

      while current_link.present?
        break if limit.is_a? Integer and counter >= limit
        current_link.when_present.click
        self.class.map_current_page self.label_value
        current_link.wait_while_present # waiting for the page to load by waiting current_link to become inactive
        block.call self
        current_page_number += 1
        current_link_locator = p.locator_value.gsub( p.finds_value.to_s, current_page_number.to_s )
        current_link = @@browser.instance_eval current_link_locator
        counter += 1
      end
    end

    def open_subpage p, n, *args
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      @@browser.instance_eval "(#{p.locator_value.to_s}).wait_until_present"
      pagination_link = @@browser.instance_eval p.locator_value
      raise PageObjectWrapper::InvalidPagination, p.locator_value+'; '+p.finds_value if not pagination_link.present?
      n_th_link_locator = p.locator_value.gsub( p.finds_value.to_s, n.to_s )
      @@browser.instance_eval "(#{n_th_link_locator}).wait_until_present"
      n_th_link = @@browser.instance_eval n_th_link_locator
      n_th_link.click
      self.class.map_current_page self.label_value
      self
    end

    def press e
      raise PageObjectWrapper::BrowserNotFound if @@browser.nil? or not @@browser.exist?
      watir_element = PageObject.return_watir_element e
      raise PageObjectWrapper::InvalidElement, "Element #{e.locator_value} not found in #{@@current_page}"\
        if not watir_element.present?
      raise PageObjectWrapper::InvalidElement, "Element #{e.locator_value} does not respond to #{e.press_action_value}"\
        if not watir_element.respond_to? e.press_action_value
      watir_element.when_present.send e.press_action_value 
      watir_element
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
end
