#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Machine < ActiveRecord::Base
  belongs_to :socle
  belongs_to :hote, :class_name => 'Machine', :foreign_key => 'hote_id'

  def to_s
    acces || 'N/A'
  end
  alias_method :nom, :to_s
end
