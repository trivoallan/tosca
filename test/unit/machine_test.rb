#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class MachineTest < Test::Unit::TestCase
  fixtures :machines, :socles

  def test_to_strings
    check_strings Machine
  end

  def test_destroy
    Machine.find(:all).each { |m|
      m.destroy
      assert Socle.find_all_by_machine_id(m.id).empty?
    }
  end

end
