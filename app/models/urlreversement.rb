#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Urlreversement < ActiveRecord::Base
  belongs_to :contribution

  validates_presence_of :valeur
  validates_presence_of :contribution_id

  def nom
    valeur
  end

  def to_s
    nom
  end

end
