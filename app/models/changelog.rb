#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Changelog < ActiveRecord::Base
  belongs_to :paquet, :counter_cache => true

  def date_modification_formatted
      display_time read_attribute(:date_modification)
  end

  def name
    self.date_modification_formatted + ' : ' << self.nom_modification << '\n' <<
      self.text_modification
  end

end
