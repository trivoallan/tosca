class Socle < ActiveRecord::Base
  has_one :machine

  has_and_belongs_to_many :clients, :uniq => true

  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'clients_socles.client_id IN (?)', client_ids ], :include => [:clients] } }
  end

end
