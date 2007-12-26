#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class CommentaireTest < Test::Unit::TestCase
  fixtures :commentaires, :demandes

  def test_to_strings
    check_strings Commentaire
  end

=begin
  def test_create_commentaire
    c = Commentaire.new

    # must have a corps > 5 characters
    assert !c.save
    c.corps= 'dd'
    assert !c.save
    c.corps= 'Voici le corps du message'
    # must have de request
    assert !c.save
    c.demande = Demande.find 3
    # must have an, author
    assert !c.save
    c.user = User.find(:first)

    assert c.save
  end

  def test_etat
    c = Commentaire.find 1
    assert_equal c.etat, 'public'
  end
=end

end
