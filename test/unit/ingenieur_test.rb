require File.dirname(__FILE__) + '/../test_helper'

class IngenieurTest < Test::Unit::TestCase
  fixtures :ingenieurs, :contracts, :competences, :users, :contracts_users

  def test_to_strings
    check_strings Ingenieur
  end

  def test_find_select_by_contract_id
    Contract.find(:all).each { |c|
      Ingenieur.find_select_by_contract_id(c.id).each { |i|
        assert c.users.include?(Ingenieur.find(i.last.to_i).user)
      }
    }
  end
  
  def test_content_column
    
  end

end
