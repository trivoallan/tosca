class Machine < ActiveRecord::Base
  belongs_to :socle
  belongs_to :hote, :class_name => 'Machine', :foreign_key => 'hote_id'

  def name
    acces || '-'
  end

end
