#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class CommentaireTest < Test::Unit::TestCase
  fixtures :commentaires, :demandes

  # Replace this with your real tests.
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

    assert c.save
  end
  def test_etat
    c = Commentaire.find 1
    assert_equal c.etat, 'private'
  end
end
