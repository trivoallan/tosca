class LoadRequestsType < ActiveRecord::Migration
  class Typedemande < ActiveRecord::Base; end

  def self.up
    # Known kind of requests
    %w(Information Anomalie Évolution Monitorat
       Intervention Étude Livraison).each{ |tr|
      Typedemande.create(:nom => tr)
    }
  end

  def self.down
    Typedemande.find(:all).each{ |td| td.destroy }
  end
end
