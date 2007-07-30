#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ChangelogTest < Test::Unit::TestCase
  fixtures :changelogs

  def test_to_s
    changelog = Changelog.find 1
    assert_equal changelog.to_s, "11.05.2005  : Thibaut LAURENT <thibaut.laurent@oxalya.com> 6.4-1.dgi\\n- Upgrade to 6.4"
  end
end
