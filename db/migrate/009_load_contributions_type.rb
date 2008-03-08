class LoadContributionsType < ActiveRecord::Migration
  class Typecontribution < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of contribution
    return unless Typecontribution.count == 0

    %w(Correction Évolution Backport).each{ |tc|
      Typecontribution.create(:nom => tc, :description => tc)
    }
  end

  def self.down
    Typecontribution.find(:all).each{ |tc| tc.destroy }
  end
end
