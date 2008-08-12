class Changelog < ActiveRecord::Base
  belongs_to :release

  def modification_date_formatted
    display_time read_attribute(:modification_date)
  end

  def name
    self.modification_date_formatted + ' : ' << read_attribute(:name) << '\n' <<
      self.modification_text
  end

end
