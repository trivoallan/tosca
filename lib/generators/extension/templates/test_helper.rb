require 'test/unit'
# Load the environment

class ExtensionTestCase < Test::Unit::TestCase
  include ExtensionFixtureTestHelper

  # Add the fixture directory to the fixture path
  self.extension_fixture_path << File.dirname(__FILE__) + "/fixtures"

  # Add more helper methods to be used by all extension tests here...

end
