#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Arch < ActiveRecord::Base
  has_many :paquets


  def to_s
    if id == 6
      '<b>src</b>'
    else
      nom
    end
  end
end
