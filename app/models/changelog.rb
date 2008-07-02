class Changelog < ActiveRecord::Base
  belongs_to :release

  def date_modification_formatted
      display_time read_attribute(:date_modification)
  end

  def name
    self.date_modification_formatted + ' : ' << self.nom_modification << '\n' <<
      self.text_modification
  end

end
