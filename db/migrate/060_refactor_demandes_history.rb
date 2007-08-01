#export RAILS_ENV=production
#rake db:migrate VERSION=57 --trace && rake db:migrate --trace
class RefactorDemandesHistory < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.record_timestamps = false
    
    add_column(:demandes, :first_comment_id, :integer)
    add_column(:demande_versions, :first_comment_id, :integer)

    add_column(:commentaires, :severite_id, :integer, :null => true)
    add_column(:commentaires, :statut_id, :integer, :null => true)
    add_column(:commentaires, :ingenieur_id, :integer, :null => true)

    add_index(:commentaires, :severite_id)
    add_index(:commentaires, :statut_id)
    add_index(:commentaires, :ingenieur_id)

    #On ignore les modification sur les champs : mail_cc
    #Nom des attributs qui peuvent varier sans changement d'état de la demande
    attributes_no_state = %w(contribution_id description resume beneficiaire_id created_on logiciel_id socle_id typedemande_id)
    old_demande_id, nb_erreurs = 0, 0
    Demande.find(:all, :order => 'id ASC').each do |d|
      old_version = nil
      d.versions.each do |v|
        #Traitement particulier pour la première version de la demande
        if v.version == 1
          new_comment = Commentaire.new
          new_comment.created_on = v.created_on - 10.seconds
          new_comment.corps = v.description
          new_comment.updated_on = v.updated_on
          new_comment.ingenieur_id = v.ingenieur_id
          new_comment.demande_id = d.id
          new_comment.severite_id = v.severite_id
          new_comment.statut_id = v.statut_id
          #Le commentaire appartient à celui qui l'a écrit
          if v.ingenieur_id.nil? #Demande déposée par un bénéficaire
            new_comment.identifiant_id = Beneficiaire.find(v.beneficiaire_id).identifiant_id
          else #Demande déposée par un ingé
            new_comment.identifiant_id = Ingenieur.find(v.ingenieur_id).identifiant_id
          end
          new_comment.save
          d.first_comment_id = new_comment.id
          d.save
        else
          #Pas de changement de statut donc juste la demande a changé
          if old_version.statut_id == v.statut_id
            if old_version.ingenieur_id != v.ingenieur_id or old_version.severite_id != v.severite_id
              new_comment = Commentaire.new
              new_comment.created_on = v.updated_on
              new_comment.updated_on = v.updated_on
              new_comment.demande_id = d.id
              new_comment.statut_id = v.statut_id

              if old_version.ingenieur_id != v.ingenieur_id
                new_comment.corps = "Le responsable de la demande a changé"
                new_comment.ingenieur_id = v.ingenieur_id
              end

              if old_version.severite_id != v.severite_id
                new_comment.severite_id = v.severite_id
                new_comment.corps = "La sévérité de la demande a changé"
              end
              if v.ingenieur_id.nil?
                new_comment.identifiant_id = nil
              else
                new_comment.identifiant_id = Ingenieur.find(v.ingenieur_id).identifiant_id
              end
              new_comment.save
            end
          else
            #Le commentaire qui a la date la plus proche de la date de création de notre version
            maybe_good_comment = d.commentaires.find(:first,
                                                     :conditions => { :prive => false },
                                                     :order => "ABS(UNIX_TIMESTAMP(created_on) - UNIX_TIMESTAMP('#{v.updated_on.strftime("%Y-%m-%d %H:%M:%S")}')) ASC")
            if maybe_good_comment.nil? #Boooo pas de commentaire :'(
              puts "Erreur : Changement d'état mais pas de commentaires ! (version " << v.version.to_s << ")"
              nb_erreurs += 1
            else
              delta = (v.updated_on - maybe_good_comment.created_on).abs
              #60 secondes
              if delta > 60.0
                puts "Erreur : Demande " << d.id.to_s << ", Version " << v.version.to_s << ", Delta " << delta.to_s
                nb_erreurs += 1
              else
                maybe_good_comment.severite_id = v.severite_id if old_version.severite_id != v.severite_id
                maybe_good_comment.statut_id = v.statut_id if old_version.statut_id != v.statut_id
                maybe_good_comment.ingenieur_id = v.ingenieur_id if old_version.ingenieur_id != v.ingenieur_id
                maybe_good_comment.save
              end
            end
          end
        end
        old_version = v
      end
    end
    puts "Erreurs : #{nb_erreurs}"

    remove_column :demandes, :version

    drop_table :demande_versions

    ActiveRecord::Base.record_timestamps = true
  end

  def self.down
  end
end
