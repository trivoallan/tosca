class LoadSoftwareClassification < ActiveRecord::Migration
  class Groupe < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Groups
    return unless Groupe.count == 0

    # Common classification for open source projects
    %w(Administration Bureautique Collaboratif Exploitation Frameworks
       Infrastructure Langage Messagerie Portail Publication Réseau
       Sécurité Serveur SGBD SIG Supervision Systeme Test).each{|g|
      Groupe.create(:nom => g)
    }
  end

  def self.down
    Groupe.find(:all).each{ |g| g.destroy }
  end
end
