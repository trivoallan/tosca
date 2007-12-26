#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class JourferieTest < Test::Unit::TestCase
  fixtures :jourferies

  def test_to_strings
    check_strings Jourferie, :jour_formatted
  end

  # Replace this with your real tests.
  def test_jour_formatted
    christmas= Jourferie.find 1
    assert_equal christmas.jour_formatted, '25.12.2006'
  end
  def test_get_premier_jour_ouvre
    day= Time.now
    christmas = Time.now.beginning_of_year - 7.days

    assert_equal day, Jourferie.get_premier_jour_ouvre(day)
    assert_equal Jourferie.get_premier_jour_ouvre(christmas), christmas + 1.day
  end
  def test_get_dernier_jour_ouvre
    day= Time.now
    christmas = Time.now.beginning_of_year - 7.days

    assert_equal day, Jourferie.get_dernier_jour_ouvre(day)
    #don't forget the week end before christmas 2006 !
    assert_equal Jourferie.get_dernier_jour_ouvre(christmas), christmas - 3.day
  end
  def test_nb_jour_ouvres
    day = Time.now
    christmas = Time.now.beginning_of_year - 7.days
    assert_equal Jourferie.nb_jours_ouvres(day, day - 1.day), 0
    assert_equal 5,
      Jourferie.nb_jours_ouvres( christmas-4.days , christmas+4.days)

  end
end
