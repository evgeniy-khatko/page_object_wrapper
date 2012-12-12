# -*- encoding : utf-8 -*-
require "watir-webdriver"
require "version"

module PageObjectWrapper
  @@pages = []
  @@driver = :firefox
  @@browser = nil
  @@domain = nil

  def self.domain=val
    @@domain=val
  end

  def self.start_browser
    @@browser = Watir::Browser.new(@@driver)
  end

  def self.stop_browser
    if not @@browser.nil?
      @@browser.close
      @@browser.quit
    end
  end

  def self.driver=val
    @@driver=val
  end

  def self.wait_interval=val
    @@browser.driver.manage.timeouts.implicit_wait= val
  end

  def self.current_page
    @@pages.select{|p| p.locator == @@browser.url}.first
  end

  def self.define_page(label, &block)
    page = PageObject.new(label)
    page.instance_eval(&block)
    @@pages << page
    page
  end

  def self.domain=val
    @@domain = val
  end

  def self.domain
    @@domain
  end

  def self.open_page(label)
    page_object = find_page_object(label)
    url = ''
    url += @@domain if page_object.locator[0]=='/'
    url += page_object.locator
    @@browser.goto url
  end

private
  def find_page_object(label)
    @@pages.select{|p| p.label == label}.first
  end
end
