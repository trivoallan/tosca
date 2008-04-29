class LoadRules < ActiveRecord::Migration
  class Ossa < ActiveRecord::Base; end
  class TimeTicket < ActiveRecord::Base; end

  def self.up
    Ossa.create(:name => 'Ossa', :max => -1)
    TimeTicket.create(:name => 'Support Gold', :max => 160)
    TimeTicket.create(:name => 'Support Silver', :max => 80)
  end

  def self.down
    Ossa.find(:all).each{ |o| o.destroy }
    TimeTicket.find(:all).each{ |tt| tt.destroy }
  end
end
