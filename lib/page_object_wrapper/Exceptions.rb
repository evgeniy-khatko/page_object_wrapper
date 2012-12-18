module PageObjectWrapper
  class UnknownFoodType < StandardError;  end
  class UnableToFeedObject < StandardError; end
  class UnknownPageObject < StandardError; end
  class UnmappedPageObject < StandardError; end
  class Load < StandardError; end
  class BrowserNotFound < StandardError; end
end
