require "watir-webdriver"
require "version"
require 'PageObject'
require 'babosa' # https://github.com/norman/babosa.git


module PageObjectWrapper
  @@domain = nil
  @@browser = nil
  @@language = :english

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
class String
  SUPPORTED_LABEL_LANGUAGES = [:bulgarian,:danish,:german,:greek,:macedonian,:norwegian,:romanian,:russian,:serbian,:spanish,:swedish,:ukrainian]
  @@label_language = :english

  def self.label_language=(l)
    raise ArgumentError, "unsupported language, supported languages: #{SUPPORTED_LABEL_LANGUAGES.inspect}\nmore: https://github.com/norman/babosa.git"\
    unless SUPPORTED_LABEL_LANGUAGES.include? l
    @@label_language = l
  end

  def self.label_language
    @@label_language
  end

  def to_label
    self.to_slug.transliterate(String.label_language).to_ruby_method.downcase
  end
end
