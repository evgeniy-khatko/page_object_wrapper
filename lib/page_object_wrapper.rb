require "watir-webdriver"
pwd = File.dirname(__FILE__) + '/'
require pwd + "version"
require pwd + 'page_object_wrapper/PageObject'

module PageObjectWrapper
  @@domain = nil
  @@browser = nil
  @@current_page = nil
  @@current_result = nil

  def self.domain=val
    @@domain=val
  end

  def self.use_browser b
    @@browser = b
    @@browser.class.send :define_method, :label_alias do |sym|
      # do nothing
    end
  end

  def self.browser
    @@browser
  end

  def self.define_page(label, &block)
    page = PageObject.new(label)
    page.instance_eval(&block)
    PageObject.pages << page
    page
  end

  def self.current_page
    @@current_page
  end

  def self.current_page= page_object
    @@current_page = page_object
  end

  def self.current_page? label
    PageObject.map_current_page label
    true
  end

  def self.current_result= res
    @@current_result = res
  end

  def self.current_result
    @@current_result
  end

  def self.current_result? post_processing, excpected_value
    real_value = @@current_result.instance_eval post_processing.to_s
    real_value == excpected_value
  end

  def self.load(path_to_pages='.')
    processed = 0
    Dir.glob("#{path_to_pages}/*.rb"){|fn|
      processed +=1
      require fn
    }
    raise PageObjectWrapper::Load, "No *.rb files found in #{path_to_pages}" if processed.zero?
    output = []
    PageObject.pages.each{|p|
      output += p.validate
    }
    raise PageObjectWrapper::Load, output.join if not output.empty?
  end

  def self.domain
    @@domain
  end

  def self.receive_page(label)
    PageObject.find_page_object(label)
  end

  def self.open_page(label, *args)
    PageObject.open_page label, *args
    PageObject.map_current_page label
  end
end
