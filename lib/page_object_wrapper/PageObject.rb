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
    @@pages = []

    REQUIRED_ELEMENT_WAIT_PERIOD = 10
    FEED_ALL = Regexp.new(/^feed_all$/)
    FEED = Regexp.new(/^feed_([\w_]+)$/)
    FIRE_ACTION = Regexp.new(/^fire_([\w_]+)$/)
    SELECT_FROM = Regexp.new(/^select_from_([\w_]+)$/)
    SELECT_ROW_FROM = Regexp.new(/^select_row_from_([\w_]+)$/)
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
          PageObjectWrapper.current_result = PageObject.return_array_of_watir_elements(eset)
        when has_element?(method_name)
          # page_object.some_element
          element = element_for(method_name)
          PageObjectWrapper.current_result = PageObject.return_watir_element element
        when FEED_ALL.match(method_name)
          # page_object.feed_all(:fresh_food)
          PageObjectWrapper.current_result = feed_elements(@elements, *args)
        when (FEED.match(method_name) and has_eset?($1))
          # page_object.feed_some_elements_set(:fresh_food)
          eset = eset_for($1)
          PageObjectWrapper.current_result = feed_elements(eset.elements, *args)
        when (FEED.match(method_name) and has_element?($1))
          # page_object.feed_some_element(:fresh_food)
          e = element_for($1)
          if [true, false].include? args[0] or args[0].is_a? String 
            PageObjectWrapper.current_result = feed_field(e, args[0])
          else
            PageObjectWrapper.current_result = feed_elements([e], *args)
          end
        when (FIRE_ACTION.match(method_name) and has_action?($1))
          # page_object.fire_some_action
          a = action_for($1)
          PageObjectWrapper.current_result = fire_action(a, *args)
        when (FIRE_ACTION.match(method_name) and has_alias?($1))
          # page_object.fire_some_action
          a = alias_for($1)
          PageObjectWrapper.current_result = fire_action(a, *args)
        when (VALIDATE.match(method_name) and has_validator?($1))
          # page_object.validate_something
          v = validator_for($1)
          PageObjectWrapper.current_result = run_validator(v, *args)
        when (SELECT_FROM.match(method_name) and has_table?($1))
          # page_object.select_from_some_table(:header_column, {:column => 'value'})
          table = table_for($1)
          PageObjectWrapper.current_result = select_from(table, *args)
        when (SELECT_ROW_FROM.match(method_name) and has_table?($1))
          # page_object.select_row_from_some_table(:number => 1, :column1 => value1, :column2 => value3, ...)
          table = table_for($1)
          PageObjectWrapper.current_result = select_row_from(table, args[0])
        when (PAGINATION_EACH.match(method_name) and has_pagination?($1))
          # page_object.each_pagination
          pagination = pagination_for($1)
          PageObjectWrapper.current_result = run_each_subpage(pagination, *args, &block)
        when (PAGINATION_OPEN.match(method_name) and has_pagination?($1))
          # page_object.open_padination(1)
          pagination = pagination_for($1)
          PageObjectWrapper.current_result = open_subpage(pagination, *args)
        when (PRESS.match(method_name) and has_element?($1))
          # page_object.press_element
          element = element_for($1)
          PageObjectWrapper.current_result = press(element)
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
        when (SELECT_ROW_FROM.match(method_name) and has_table?($1))
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
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil?
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
      PageObjectWrapper.browser.goto url
    end

    def self.map_current_page label
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil?
      page_object = PageObject.find_page_object(label)
      page_object.elements.select{ |e| e.required_value == true }.each{ |required_element|
        begin
          watir_element = return_watir_element required_element
          watir_element.wait_until_present REQUIRED_ELEMENT_WAIT_PERIOD
        rescue Watir::Wait::TimeoutError => e
          raise PageObjectWrapper::UnmappedPageObject, "#{label} <=> #{PageObjectWrapper.browser.url} (#{e.message})" if not watir_element.present?
        end
      }
      PageObjectWrapper.current_page = page_object
    end

    def self.pages
      @@pages
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
      begin
        a.instance_eval( &block )
      rescue # rescue any exception, because only action_alias method is known for POW inside
      end    # current block
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
      begin
        v.instance_eval( &block )
      rescue # rescue any exception, because only action_alias method is known for POW inside
      end    # current block
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
      raise PageObjectWrapper::Load, "\tpage_object #{label_value.inspect} already defined\n" if PageObject.labeled(@@pages).count(label_value) > 1
      output << "\tlabel #{label_value.inspect} not a Symbol\n" if not label_value.is_a?(Symbol)
      output << "\tlabel aliases #{label_alias_value.inspect} not an Array of Symbols\n" if (not label_alias_value.empty?) and label_alias_value.collect(&:class).uniq != [Symbol]
      output << "\tlocator #{locator_value.inspect} not a meaningful String\n" if not locator_value.is_a?(String) or locator_value.empty?
      @esets.each{|eset|
        eset_output = []
        eset_output << "\telements_set #{eset.label_value.inspect} already defined\n" if PageObject.labeled(@esets).count(eset.label_value) > 1
        eset_output << "\tlabel #{eset.label_value.inspect} not a Symbol\n" if not eset.label_value.is_a?(Symbol)
        eset_output << "\tlabel aliases #{eset.label_alias_value.inspect} not an Array of Symbols\n" if (not eset.label_alias_value.empty?) and eset.label_alias_value.collect(&:class).uniq != [Symbol]
        eset_output.unshift "elements_set(#{eset.label_value.inspect}):\n" if not eset_output.empty?
        output += eset_output
      }
      @elements.each{|e|
        element_output = []
        element_output << "\telement #{e.label_value.inspect} already defined\n" if PageObject.labeled(@elements).count(e.label_value) > 1
        element_output << "\tlabel #{e.label_value.inspect} not a Symbol\n" if not e.label_value.is_a?(Symbol)
        element_output << "\tlabel aliases #{e.label_alias_value.inspect} not an Array of Symbols\n" if (not e.label_alias_value.empty?) and e.label_alias_value.collect(&:class).uniq != [Symbol]
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
        action_output << "\taction #{a.label_value.inspect} already defined\n" if PageObject.labeled(@actions).count(a.label_value) > 1
        action_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
        action_output << "\tlabel aliases #{a.label_alias_value.inspect} not an Array of Symbols\n" if (not a.label_alias_value.empty?) and a.label_alias_value.collect(&:class).uniq != [Symbol]
        if not a.next_page_value.nil?
          action_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
          action_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not PageObject.labeled(@@pages).include?(a.next_page_value)
        end
        action_output << "\tfire event is not a Proc\n" if not a.fire_block_value.is_a?(Proc)
        action_output.unshift "action(#{a.label_value.inspect}):\n" if not action_output.empty?
        output += action_output
      }
      @aliases.each{|a|
        alias_output = []
        alias_output << "\talias #{a.label_value.inspect} already defined\n" if PageObject.labeled(@aliases).count(a.label_value) > 1
        alias_output << "\tlabel #{a.label_value.inspect} not a Symbol\n" if not a.label_value.is_a?(Symbol)
        alias_output << "\tlabel aliases #{a.label_alias_value.inspect} not an Array of Symbols\n" if (not a.label_alias_value.empty?) and a.label_alias_value.collect(&:class).uniq != [Symbol]
        if not a.next_page_value.nil?
          alias_output << "\tnext_page #{a.next_page_value.inspect} not a Symbol\n" if not a.next_page_value.is_a? Symbol
          alias_output << "\tnext_page #{a.next_page_value.inspect} unknown page_object\n" if not PageObject.labeled(@@pages).include?(a.next_page_value)
        end
        alias_output << "\taction #{a.action_value.inspect} not known Action\n" if not PageObject.labeled(@actions).include? a.action_value
        alias_output.unshift "alias(#{a.label_value.inspect}):\n" if not alias_output.empty?
        output += alias_output
      }
      @validators.each{|v|
        validator_output = []
        validator_output << "\tvalidator #{v.label_value.inspect} already defined\n" if PageObject.labeled(@validators).count(v.label_value) > 1
        validator_output << "\tlabel #{v.label_value.inspect} not a Symbol\n" if not v.label_value.is_a?(Symbol)
        validator_output << "\tlabel aliases #{v.label_alias_value.inspect} not an Array of Symbols\n" if (not v.label_alias_value.empty?) and v.label_alias_value.collect(&:class).uniq != [Symbol]
        validator_output << "\tvalidation block is not a Proc\n" if not v.validate_block_value.is_a?(Proc)
        validator_output.unshift "validator(#{v.label_value.inspect}):\n" if not validator_output.empty?
        output += validator_output
      }
      @tables.each{|t|
        table_output = []
        table_output << "\ttable #{t.label_value.inspect} already defined\n" if PageObject.labeled(@tables).count(t.label_value) > 1
        table_output << "\tlabel #{t.label_value.inspect} not a Symbol\n" if not t.label_value.is_a?(Symbol)
        table_output << "\tlabel aliases #{t.label_alias_value.inspect} not an Array of Symbols\n" if (not t.label_alias_value.empty?) and t.label_alias_value.collect(&:class).uniq != [Symbol]
        table_output << "\theader #{t.header_value.inspect} not a meaningful Array\n" if not t.header_value.is_a?(Array) or t.header_value.empty?
        table_output.unshift "table(#{t.label_value.inspect}):\n" if not table_output.empty?
        output += table_output
      }
      @paginations.each{|p|
        pagination_output = []
        pagination_output << "\tpagination #{p.label_value.inspect} already defined\n" if PageObject.labeled(@paginations).count(p.label_value) > 1
        pagination_output << "\tlabel #{p.label_value.inspect} not a Symbol\n" if not p.label_value.is_a?(Symbol)
        pagination_output << "\tlabel aliases #{p.label_alias_value.inspect} not an Array of Symbols\n" if (not p.label_alias_value.empty?) and p.label_alias_value.collect(&:class).uniq != [Symbol]
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
      raise PageObjectWrapper::UnknownPageObject, l.inspect unless PageObject.labeled( @@pages ).include? l
      @@pages.select{|p| p.label_value == l or p.label_alias_value.include?(l)}.first
    end
    
    def self.return_watir_element(e)
      el = nil
      if e.locator_value.is_a? Hash
        el = PageObjectWrapper.browser.send e.type, e.locator_value
      elsif e.locator_value.is_a? String
        el = PageObjectWrapper.browser.instance_eval e.locator_value
      end
      el
    end

    def self.return_array_of_watir_elements(eset)
      eset.elements.collect{|e| return_watir_element(e)}
    end

    def feed_elements(elements, *args)
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      menu_name, cheef_menu = nil, nil
      watir_elements = []
      
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
        watir_elements << watir_element
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
              #raise PageObjectWrapper::UnableToFeedObject, to_tree(PageObjectWrapper.current_page, e) + ' check element type'
            end
          end
      }
      watir_elements
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
      watir_element
    end


    def fire_action(a, *args)
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      block = (a.is_a? Action)? a.fire_block_value : action_for(a.action_value).fire_block_value
      block_result = PageObjectWrapper.browser.instance_exec *args, &block
      if not a.next_page_value.nil?
        self.class.map_current_page a.next_page_value
        return PageObjectWrapper.current_page
      else
        return block_result
      end 
    end

    def run_validator(v, *args)
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      PageObjectWrapper.browser.instance_exec *args, &v.validate_block_value
    end

    def select_from(table, header, *args)
      where = args[0]
      next_page = args[1]
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      PageObjectWrapper.browser.table(table.locator_value).wait_until_present
      t = PageObjectWrapper.browser.table(table.locator_value)
      raise ArgumentError, "#{header.inspect} not a Symbol" if not header.is_a? Symbol
      raise ArgumentError, "#{header.inspect} not in table header" if not table.header_value.include? header
      search_for_index = table.header_value.index(header)
      found = nil

      if not next_page.nil?
        raise ArgumentError, "#{next_page.inspect} not a Symbol" if not next_page.is_a? Symbol
        raise ArgumentError, "#{next_page.inspect} not known Page" if not PageObject.labeled(@@pages).include?(next_page)
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
            found = t.rows[search_value].cells[search_for_index] # +1 because we want rows to start from 0 (similar to columns)
          rescue Watir::Exception::UnknownObjectException
            found = nil
          end
        else # finding by String or Regexp
          search_in_index = table.header_value.index(where.keys.first)
          t.rows.each{|r|
            if search_value.is_a? String
              begin 
                if r.cells[search_in_index].checkbox.present? and r.cells[search_in_index].checkbox.set?.to_s == search_value
                  found = r.cells[search_for_index] 
                  break
                elsif r.cells[search_in_index].radio.present? and r.cells[search_in_index].radio.set?.to_s == search_value
                  found = r.cells[search_for_index] 
                  break
                elsif r.cells[search_in_index].text == search_value
                  found = r.cells[search_for_index] 
                  break
                end
              rescue Watir::Exception::UnknownObjectException
                found = nil
                next
              end
            elsif search_value.is_a? Regexp
              begin
                if search_value.match(r.cells[search_in_index].text)
                  found = r.cells[search_for_index] 
                  break
                end
              rescue Watir::Exception::UnknownObjectException
                found = nil
                next
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

    def select_row_from(table, query)
      conditions = query.clone
      conditions.delete(:number)
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      PageObjectWrapper.browser.table(table.locator_value).wait_until_present
      t = PageObjectWrapper.browser.table(table.locator_value)
      found_row = {}
      candidate_rows = nil
      raise ArgumentError, "argument should be a meaningful Hash, got #{query.inspect}" if not query.is_a?(Hash) or query.empty?
      if query.has_key?(:number) and query[:number].class != Fixnum
        raise ArgumentError, "arguments key :number should have Integer value, got #{query[:number].class}"
      end
      if not conditions.empty? and (conditions.keys.collect(&:class).uniq != [Symbol] or conditions.values.collect(&:class).uniq != [String])
        raise ArgumentError, "arguments hash should be like :symbol => 'a string' (for all columns except :number), got #{query.inspect}"
      end
      
      if query.has_key? :number
        candidate_rows = [t[query[:number]]]
        query.delete(:number)
      else
        candidate_rows = t.rows
      end

      candidate_rows.each{ |r|
        conditions_met = true
        unless query.empty?
          query.each_key{ |column_name|
            raise ArgumentError, "column #{column_name.inspect} not in table header and not == :number" if not table.header_value.include?(column_name) 
            column_index = table.header_value.index(column_name)
            column_text = ''
            # workaround for rows with small number of columns
            begin
              if r[column_index].checkbox.present?
                column_text = r[column_index].checkbox.set?.to_s
              elsif r[column_index].radio.present?
                column_text = r[column_index].radio.set?.to_s
              else
                column_text = r[column_index].text
              end
            rescue Watir::Exception::UnknownObjectException
              # just moving to next row
              conditions_met = false
              break
            end
            conditions_met = false if column_text != query[column_name]
          }
        end
        if conditions_met
          column_index = 0
          r.cells.each{ |cell| 
            found_row[table.header_value[column_index]] = cell
            column_index += 1
          }
          return found_row
        end
      }
      return nil
    end

    def run_each_subpage(p, opts=nil, &block)
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      limit = opts[:limit] if not opts.nil?
      raise PageObjectWrapper::InvalidPagination, opts.inspect if limit < 0 if not limit.nil?
      result = nil

      PageObjectWrapper.browser.instance_eval "(#{p.locator_value}).wait_until_present"
      current_link = PageObjectWrapper.browser.instance_eval p.locator_value
      raise PageObjectWrapper::InvalidPagination, p.locator_value+'; '+p.finds_value if not current_link.present?
      current_page_number = p.finds_value.to_i
      counter = 0

      while current_link.present?
        break if limit.is_a? Integer and counter >= limit
        current_link.when_present.click
        self.class.map_current_page self.label_value
        current_link.wait_while_present # waiting for the page to load by waiting current_link to become inactive
        result = block.call self
        current_page_number += 1
        current_link_locator = p.locator_value.gsub( p.finds_value.to_s, current_page_number.to_s )
        current_link = PageObjectWrapper.browser.instance_eval current_link_locator
        counter += 1
      end
      result
    end

    def open_subpage p, n, *args
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      PageObjectWrapper.browser.instance_eval "(#{p.locator_value.to_s}).wait_until_present"
      pagination_link = PageObjectWrapper.browser.instance_eval p.locator_value
      raise PageObjectWrapper::InvalidPagination, p.locator_value+'; '+p.finds_value if not pagination_link.present?
      n_th_link_locator = p.locator_value.gsub( p.finds_value.to_s, n.to_s )
      PageObjectWrapper.browser.instance_eval "(#{n_th_link_locator}).wait_until_present"
      n_th_link = PageObjectWrapper.browser.instance_eval n_th_link_locator
      n_th_link.click
      self.class.map_current_page self.label_value
      self
    end

    def press e
      raise PageObjectWrapper::BrowserNotFound if PageObjectWrapper.browser.nil? or not PageObjectWrapper.browser.exist?
      watir_element = PageObject.return_watir_element e
      raise PageObjectWrapper::InvalidElement, "#{e.type_value} #{e.locator_value} not found in #{PageObjectWrapper.current_page.label_value}"\
        if not watir_element.present?
      raise PageObjectWrapper::InvalidElement, "#{e.type_value} #{e.locator_value} does not respond to #{e.press_action_value}"\
        if not watir_element.respond_to? e.press_action_value
      watir_element.when_present.send e.press_action_value 
      watir_element
    end

    def self.labeled(ary)
      labels = ary.collect(&:label_value)
      label_aliases = []
      ary.each{ |obj| label_aliases += obj.label_alias_value }
      labels + label_aliases
    end

    [:eset, :element, :table, :pagination, :action, :alias, :validator].each{|el|
      PageObject.send :define_method, 'has_'+el.to_s+'?' do |label| # has_xxx?(label)
        PageObject.labeled(instance_variable_get("@#{el.to_s.pluralize}")).include?(label.to_sym)
      end
      PageObject.send :define_method, el.to_s+'_for' do |label| # xxx_for(label)
        instance_variable_get("@#{el.to_s.pluralize}").each{ |obj|
          return obj if obj.label_value == label.to_sym or obj.label_alias_value.include? label.to_sym
        }
        raise ArgumentError, "cant define method #{ el.to_s + '_for' } because @#{el.to_s.pluralize} doesnt have element with label #{label.inspect}"
      end
    }
  end
end
