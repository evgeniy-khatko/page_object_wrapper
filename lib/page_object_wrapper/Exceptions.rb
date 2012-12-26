module PageObjectWrapper
  class UnknownMenuType < StandardError;  end
  class UnableToFeedObject < StandardError; end
  class UnknownPageObject < StandardError; end
  class UnmappedPageObject < StandardError; end
  class Load < StandardError; end
  class BrowserNotFound < StandardError; end
  class DynamicUrl < StandardError; end
end
