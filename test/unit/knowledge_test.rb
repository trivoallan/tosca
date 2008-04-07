require File.dirname(__FILE__) + '/../test_helper'

class KnowledgeTest < ActiveSupport::TestCase
  fixtures :knowledges

  # Common test, see the Wiki for more info
  def test_to_strings
    check_strings Knowledge
  end


end
