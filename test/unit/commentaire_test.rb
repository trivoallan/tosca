require File.dirname(__FILE__) + '/../test_helper'

class CommentaireTest < Test::Unit::TestCase
  fixtures :commentaires, :demandes, :users

  def test_to_strings
    check_strings Commentaire
  end

  # We ensure to call all the methods
  def test_helper_methods
    c = Commentaire.find :first
    c.etat
    c.mail_id
    assert !c.add_attachment({})
    c.fragments
  end

  def test_create_commentaire
    c = Commentaire.new(:corps => 'this is a comment',
                        :demande => Demande.find(:first),
                        :user => User.find(:first))
    assert c.save!
    c = Commentaire.new(:corps => 'this is a comment',
                        :demande => Demande.find(:first),
                        :user => User.find(:first),
                        :prive => false, :statut_id => 1)
    assert c.save!
    # cannot change privately the status
    c = Commentaire.new(:corps => 'this is a comment',
                        :demande => Demande.find(:first),
                        :user => User.find(:first),
                        :prive => true, :statut_id => 1)
    assert !c.save
    # cannot declare a comment without a request
    c = Commentaire.new(:corps => 'this is a comment',
                        :user => User.find(:first),
                        :prive => true, :statut_id => 1)
    assert !c.save
  end

  # last call to destroy will cover the special case of update_status
  def test_update_status
    d = Demande.find(:first)
    d.commentaires.each { d.destroy }
  end
  
  def test_create_commentaire_without_corps
    #Should not work
    Statut::NEED_COMMENT.each do |s|
      c = Commentaire.new(:corps => "",
        :demande => Demande.find(:first),
        :user => User.find(:first),
        :prive => false, :statut_id => s)
      assert_equal(false, c.save)
    end

    #Should work
    ([1,2,3,4,5,6,7,8] - Statut::NEED_COMMENT).each do |s|
      c = Commentaire.new(:corps => "",
        :demande => Demande.find(:first),
        :user => User.find(:first),
        :prive => false, :statut_id => s)
      assert c.save!
    end
  end

end
