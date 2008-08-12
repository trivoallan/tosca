class Changelog < ActiveRecord::Base
  belongs_to :release

  def modification_date_formatted
    display_time read_attribute(:modification_date)
  end

  def name
    puts "---"
    puts self.modification_date_formatted
    puts "---"
    puts read_attribute(:name)
    puts "---"
    puts self.modification_text
    puts "---"
    self.modification_date_formatted + ' : ' << read_attribute(:name) << '\n' <<
      self.modification_text
  end

end
