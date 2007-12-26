#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Machine < ActiveRecord::Base
  belongs_to :socle, :dependent => :destroy
  belongs_to :hote, :class_name => 'Machine', :foreign_key => 'hote_id'

  def name
    acces || '-'
  end
end
