#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class TypeurlTest < Test::Unit::TestCase
  fixtures :typeurls

  def test_to_strings
    check_strings Typeurl
  end

end
