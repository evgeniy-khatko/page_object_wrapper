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
    PageObject.browser = Watir::Browser.new(@@driver)
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
