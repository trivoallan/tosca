class LoadRequestsType < ActiveRecord::Migration
  class Typedemande < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of requests
    return unless Typedemande.count == 0

    id = 1
    %w(Information Anomalie Évolution Monitorat
       Intervention Étude Livraison).each{ |tr|
      td = Typedemande.new(:nom => tr); td.id = id; td.save
      id = id + 1
    }
  end

  def self.down
    Typedemande.find(:all).each{ |td| td.destroy }
  end
end
