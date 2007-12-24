class LoadSeverities < ActiveRecord::Migration
  class Severite < ActiveRecord::Base; end

  def self.up
    # known kind of urls for a software
    id = 1
    %w(Bloquante Majeure Mineure Aucune).each {|n|
      s = Severite.new(:nom => n)
      s.id = id
      s.save
      id = id + 1
    }
  end

  def self.down
    Severite.find(:all).each{ |s| s.destroy }
  end
end
