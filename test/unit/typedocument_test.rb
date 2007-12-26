#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class TypedocumentTest < Test::Unit::TestCase
  fixtures :typedocuments

  def test_to_strings
    check_strings Typedocument
  end
end
