require File.dirname(__FILE__) + '/../test_helper'

class IngenieurTest < Test::Unit::TestCase
  fixtures :ingenieurs, :contrats, :competences, :users, :contrats_users

  def test_to_strings
    check_strings Ingenieur
  end

  def test_find_select_by_contrat_id
    Contrat.find(:all).each { |c|
      Ingenieur.find_select_by_contrat_id(c.id).each { |i|
        assert c.users.include?(Ingenieur.find(i.last.to_i).user)
      }
    }
  end

=begin
  TODO : Deprecated
  def test_find_ossa
    i = Ingenieur.find 1,2,3
    assert_equal Ingenieur.find_ossa(:all), i
  end
  def test_find_presta
    i = Ingenieur.find 4
    assert_equal Ingenieur.find_presta(:all), [i]
  end
=end
end
