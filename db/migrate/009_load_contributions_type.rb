class LoadContributionsType < ActiveRecord::Migration
  class Typecontribution < ActiveRecord::Base; end

  def self.up
    # Known kind of contributions
    %w(Correction Évolution Backport).each{|tc|
      Typecontribution.create(:nom => tc)
    }
  end

  def self.down
    Typecontribution.find(:all).each{ |tc| tc.destroy }
  end
end
