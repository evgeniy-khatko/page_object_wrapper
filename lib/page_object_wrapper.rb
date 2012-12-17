# -*- encoding : utf-8 -*-
require "watir-webdriver"
require "version"
require 'PageObject'

module PageObjectWrapper

  @@domain = nil
  @@browser = nil

  def self.domain=val
    @@domain=val
  end

  def self.use_browser b
    PageObject.browser = b
  end

  def self.browser
    PageObject.browser
  end

  def self.define_page(label, &block)
    page = PageObject.new(label)
    page.instance_eval(&block)
    PageObject.pages << page
    page
  end

  def self.current_page
    PageObject.current_page
  end

  def self.load(path_to_pages='.')
    processed = 0
    Dir.glob("#{path_to_pages}/*_page.rb"){|fn|
      processed +=1
      require fn
    }
    raise PageObjectWrapper::Load, "No *_page.rb files found in #{path_to_pages}" if processed.zero?
    output = []
    PageObject.pages.each{|p|
      output += p.validate
    }
    raise PageObjectWrapper::Load, output.join if not output.empty?
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
