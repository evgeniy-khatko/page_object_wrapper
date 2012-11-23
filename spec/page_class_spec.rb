# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "PageObjectWrapper" do
	let(:google_search_page_class){
		class GoogleSearchPage < PageObjectWrapper::Page
			attr_accessor :find_form
			@url="/"
			def initialize visit=false 
				super visit
			end
		end
		GoogleSearchPage
	}

	it "has .stop_browser method which closes browser" do
		PageObjectWrapper.stop_browser
		PageObjectWrapper::Page.accessor.should_not exist
	end

	it "has .start_browser method which puts Watir::Browser.new to Page.accessor by default" do
		PageObjectWrapper.start_browser
		PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
		PageObjectWrapper.stop_browser
	end

	it "has .restart_browser method which restart current browser" do
		PageObjectWrapper.start_browser
		PageObjectWrapper.restart_browser
		PageObjectWrapper::Page.accessor.should be_a(Watir::Browser)
		PageObjectWrapper.stop_browser
	end

	it "has .domain= method which reprsents the domain of DUT" do
		PageObjectWrapper.start_browser
		PageObjectWrapper.domain = 'www.google.com'
		google_search_page_class.new(true)
		PageObjectWrapper::Page.accessor.title.should eq('Google')
		PageObjectWrapper.stop_browser
	end

	it "has .timeout= method which sets implicit timeout for webdriver (default is 5 sec)" do
		pending "not working yet"
	end
end

describe "GoogleSearchPage class instance in general" do
	let(:google_search_page_class){
		class GoogleSearchPage < PageObjectWrapper::Page
			attr_accessor :find_form
			@url="/"
			def initialize visit=false 
				super visit
			end
		end
		GoogleSearchPage
	}

	its "class has @url class variable which can be treated as Page specific url" do
			google_search_page_class.url.should eq('/')
	end

	its "instanciation with \'true\' is similar to openning page in browser" do
		PageObjectWrapper.start_browser
		google_search_page = google_search_page_class.new(true)
		google_search_page_class.accessor.title.should eq('Google')
	end

	its "instantiation with \'false\' just returns new instanse, but does not opens browser on that page" do
		PageObjectWrapper.restart_browser
		google_search_page = google_search_page_class.new(false)
		google_search_page_class.accessor.title.should_not eq('Google')
	end
end
