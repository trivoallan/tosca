#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ChangelogTest < Test::Unit::TestCase
  fixtures :changelogs

  def test_to_strings
    check_strings Changelog
  end
end
