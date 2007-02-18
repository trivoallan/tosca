#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Socle < ActiveRecord::Base
  has_one :machine, :dependent => :destroy
  has_many :binaires
  has_many :paquets, :through => :binaires, :group => 'paquets.id' 

  has_and_belongs_to_many :clients


  def self.set_scope(client_id)
    self.scoped_methods << { :find => { :conditions => 
        [ 'clients.id = ?', client_id ],
        :include => [:clients]} }
  end


  def to_s
    nom
  end
end
