require 'test/unit'
# Load the environment

class Test::Unit::TestCase

  # Add the fixture directory to the fixture path
  self.fixture_path << File.dirname(__FILE__) + "/fixtures"

  # Add more helper methods to be used by all extension tests here...

end
