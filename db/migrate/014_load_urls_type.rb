class LoadUrlsType < ActiveRecord::Migration
  class Typeurl < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of software's urls
    return unless Typeurl.count == 0

    # known kind of urls for a software
    %w(blog forge contact homepage bugtracker sources
       mailing documentation changelog).each {|tu|
      Typeurl.create(:nom => tu)
    }
  end

  def self.down
    Typeurl.find(:all).each{ |tu| tu.destroy }
  end
end
