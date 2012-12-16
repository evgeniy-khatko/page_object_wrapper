# -*- encoding : utf-8 -*-
require "watir-webdriver"
require "version"
require 'PageObject'

module PageObjectWrapper



  @@driver = :firefox
  @@domain = nil

  def self.domain=val
    @@domain=val
  end

  def self.start_browser
    PageObject.browser = Watir::Browser.new @@driver
  end

  def self.stop_browser
    if not PageObject.browser.nil?
      PageObject.browser.close
      PageObject.browser.quit
    end
  end

  def self.driver=val
    @@driver=val
  end

  def self.wait_interval=val
    PageObject.browser.driver.manage.timeouts.implicit_wait= val
  end

  def self.define_page(label, &block)
    page = PageObject.new(label)
    page.instance_eval(&block)
    PageObject.pages << page
    page
  end

  def self.load
    PageObject.pages.each{|p|
      p.validate_label
      p.validate_locator
      p.validate_uniq_element

      p.esets.each{|eset|
        eset.validate_label
        eset.validate_uniqueness
        eset.each{|e|
          e.validate_label
          e.validate_locator
          e.validate_uniqueness
        }
      }

      p.actions.each{|a|
        a.validate_action_label
        a.validate_action_next_page
        a.validate_action_fire_proc
        a.validate_uniqueness
      }

      p.tables.each{|t|
        t.validate_label
        t.validate_locator
        t.validate_uniqueness
      }

      p.paginations{|pag|
        pag.validate_pagination_label
        pag.validate_pagination_locator    
        pag.validate_uniqueness
      }

      p.validate_uniqueness
    }
  end

  def self.domain=val
    @@domain = val
  end

  def self.domain
    @@domain
  end

  def self.open_page(label)
    PageObject.map_current_page label
  end
end
