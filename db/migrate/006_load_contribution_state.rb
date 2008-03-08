class LoadContributionState < ActiveRecord::Migration
  class Etatreversement < ActiveRecord::Base; end

  def self.up
    # Do not erase existing states
    return unless Etatreversement.count == 0

    # Known state for a contribution
    Etatreversement.create(:nom => 'rejetée', :description =>
                           'Correctif soumis mais non accepté par la communauté.')
    Etatreversement.create(:nom => 'non reversée', :description =>
                           "Ce correctif n'est pas reversé à la communauté. C'est souvent le cas des backport.")
    Etatreversement.create(:nom => 'acceptée', :description =>
                           'Correctif accepté dans la branche principale du projet.')
    Etatreversement.create(:nom => 'proposée', :description =>
                           "Échanges en cours pour déterminer les modalités d'intégration du correctif.")
  end

  def self.down
    Etatreversement.find(:all).each{ |er| er.destroy }
  end
end
