class LoadUrlsType < ActiveRecord::Migration
  class Typeurl < ActiveRecord::Base; end

  def self.up
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
