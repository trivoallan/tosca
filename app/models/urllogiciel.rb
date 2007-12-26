#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Urllogiciel < ActiveRecord::Base
  belongs_to :typeurl
  belongs_to :logiciel

  validates_presence_of :valeur
  validates_presence_of :logiciel

  def name
    valeur
  end

end
