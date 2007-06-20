#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Changelog < ActiveRecord::Base
  belongs_to :paquet, :counter_cache => true

  def date_modification_formatted
    d = @attributes['date_modification']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} "
  end

  def to_s
    c.date_modification_formatted + ' : ' << c.nom_modification << '\n' << 
      c.text_modification
  end

end
