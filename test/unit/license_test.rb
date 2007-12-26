#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class LicenseTest < Test::Unit::TestCase
  fixtures :licenses

  def test_to_strings
    check_strings License
  end

end
