class LoadDocumentsType < ActiveRecord::Migration
  class Typedocument < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of documents
    return unless Typedocument.count == 0

    [ [ 'Bon de commande', "Bon des Unités d'Oeuvre commandés dans le cadre de marché Support Logiciel Libre." ],
      [ 'Compte-Rendu', 'Compte-Rendu des différentes réunions ayant eu lieu dans le cadre de votre contract.' ],
      [ 'Service', 'Documents qualités sur notre fonctionnement.' ],
      [ 'Veille', "Rapports de veille technologique, ciblant des sujets d'actualité pointus" ],
      [ 'Newsletter', "Lettre d'information mensuel sur votre périmètre logiciel." ],
      [ 'Audit', "Rapport d'audit sur des éléments logiciels ou matériels précis" ],
      [ 'Documentation', "Regroupe l'ensemble des livrables associés à un développement réalisé dans le cadre d'une Unité d'Oeuvre ou de votre contract." ]
    ].each{ |td|
      Typedocument.create(:nom => td.first, :description => td.last)
    }
  end

  def self.down
    Typedocument.find(:all).each{ |td| td.destroy }
  end
end
