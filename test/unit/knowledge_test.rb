require File.dirname(__FILE__) + '/../test_helper'

class KnowledgeTest < ActiveSupport::TestCase
  fixtures :knowledges, :competences, :logiciels, :ingenieurs

  # Common test, see the Wiki for more info
  def test_to_strings
    check_strings Knowledge
  end

  def test_validation
    obj = Knowledge.new(:competence => nil, :logiciel => nil)
    assert !obj.valid?
    obj = Knowledge.new(:competence => Competence.find(:first),
                        :logiciel => Logiciel.find(:first),
                        :ingenieur => Ingenieur.find(:first),
                        :level => 3)
    assert !obj.valid?
    obj.competence = nil
    assert obj.valid?
  end
end
