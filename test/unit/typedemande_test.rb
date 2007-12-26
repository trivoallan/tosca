#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class TypedemandeTest < Test::Unit::TestCase
  fixtures :typedemandes

  def test_to_strings
    check_strings Typedemande
  end

end
