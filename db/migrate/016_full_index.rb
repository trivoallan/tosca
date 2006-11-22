class FullIndex < ActiveRecord::Migration
  def self.up
    add_index :beneficiaires, :client_id
    add_index :beneficiaires, :beneficiaire_id
    add_index :beneficiaires, :identifiant_id

    add_index :changelogs, :paquet_id

    add_index :clients, :photo_id
    add_index :clients, :support_id

    add_index :commentaires, :demande_id
    add_index :commentaires, :piecejointe_id
    add_index :commentaires, :identifiant_id

    add_index :competences_ingenieurs, :ingenieur_id
    add_index :competences_ingenieurs, :competence_id

    add_index :competences_logiciels, :logiciel_id
    add_index :competences_logiciels, :competence_id

    add_index :contrats, :client_id

    add_index :contrats_ingenieurs, :ingenieur_id
    add_index :contrats_ingenieurs, :contrat_id
    
    add_index :demandechanges, :identifiant_id
    add_index :demandechanges, :demande_id

    add_index :demandes, :beneficiaire_id
    add_index :demandes, :ingenieur_id
    add_index :demandes, :severite_id
    add_index :demandes, :typedemande_id
    remove_column :demandes, :piecejointe_id

    add_index :demandes_paquets, :paquet_id
    add_index :demandes_paquets, :demande_id

    add_index :documents, :identifiant_id
    add_index :documents, :typedocument_id
    add_index :documents, :client_id

    remove_index :engagements, :severite_id
    remove_index :engagements, :typedemande_id
    add_index :engagements, [:severite_id, :typedemande_id]

    remove_column :identifiants, :groupe_id

    add_index :ingenieurs, :identifiant_id

    add_index :reversements, :correctif_id

    add_index :urllogiciels, :logiciel_id
    add_index :urllogiciels, :typeurl_id
  end

  def self.down
    remove_index :beneficiaires, :client_id
    remove_index :beneficiaires, :beneficiaire_id
    remove_index :beneficiaires, :identifiant_id

    remove_index :changelogs, :paquet_id

    remove_index :clients, :photo_id
    remove_index :clients, :support_id

    remove_index :commentaires, :demande_id
    remove_index :commentaires, :piecejointe_id
    remove_index :commentaires, :identifiant_id

    remove_index :competences_ingenieurs, :ingenieur_id
    remove_index :competences_ingenieurs, :competence_id

    remove_index :competences_logiciels, :logiciel_id
    remove_index :competences_logiciels, :competence_id

    remove_index :contrats, :client_id

    remove_index :contrats_ingenieurs, :ingenieur_id
    remove_index :contrats_ingenieurs, :contrat_id
    
    remove_index :demandechanges, :identifiant_id
    remove_index :demandechanges, :demande_id

    remove_index :demandes, :beneficiaire_id
    remove_index :demandes, :ingenieur_id
    remove_index :demandes, :severite_id
    remove_index :demandes, :typedemande_id
    add_column :demandes, :piecejointe_id

    remove_index :demandes_paquets, :paquet_id
    remove_index :demandes_paquets, :demande_id

    remove_index :documents, :identifiant_id
    remove_index :documents, :typedocument_id
    remove_index :documents, :client_id

    remove_index :engagements, [:severite_id, :typedemande_id]
    add_index :engagements, :severite_id
    add_index :engagements, :typedemande_id

    add_column :identifiants, :groupe_id

    remove_index :ingenieurs, :identifiant_id

    remove_index :reversements, :correctif_id

    remove_index :urllogiciels, :logiciel_id
    remove_index :urllogiciels, :typeurl_id

  end
end
