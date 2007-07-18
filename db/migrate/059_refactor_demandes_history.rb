#export RAILS_ENV=production
#rake db:migrate VERSION=57 --trace && rake db:migrate --trace   
class RefactorDemandesHistory < ActiveRecord::Migration
  def self.up
#     add_column(:commentaires, :severite_id, :integer, :null => true)
#     add_column(:commentaires, :statut_id, :integer, :null => true)
#     add_column(:commentaires, :ingenieur_id, :integer, :null => true)

#     add_index(:commentaires, :severite_id)
#     add_index(:commentaires, :statut_id)
#     add_index(:commentaires, :ingenieur_id)

    #On ignore les modification sur les champs : mail_cc
    #Nom des attributs qui peuvent varier sans changement d'état de la demande
    attributes_no_state = %w(contribution_id description resume beneficiaire_id created_on logiciel_id socle_id typedemande_id)
    #Nom des attributs d'une demande qui ne devraient vraiment pas être égaux d'une version à l'autre
    attributes_bug = %w(updated_on)
    #Nom des attributs qui si ils sont égaux d'une version à une autre résultent d'un bug de plugin act_as_version
    attributes_error = %w(version)
    old_demande_id = 0
    nb_erreurs = 0
    vilaine_demandes = [113, 115, 123, 126, 128, 131, 151, 154, 158, 207, 209, 211, 214, 215, 217, 218, 219, 220, 221, 224, 226, 227, 228, 232, 236, 239, 251, 306]
    Demande.find(:all, :order => 'id ASC').each do |d|
      old_version = nil
    
      if (d.versions[0] and d.versions[0].beneficiaire_id == 17) or (vilaine_demandes.member? d.id)
      else
      d.versions.each do |v|
        #Traitement particulier pour la première version de la demande
        if v.version == 1 
          new_comment = Commentaire.new
          new_comment.created_on = v.created_on
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
#           puts "Création nouveau commentaire pour demande #{d.id}"
#           new_comment.save
        else
          #Pas de changement de statut donc juste la demande a changé
          if old_version.statut_id == v.statut_id
            #Si l'ingénieur a changé
            if old_version.ingenieur_id != v.ingenieur_id
              new_comment = Commentaire.new
              new_comment.created_on = v.created_on
              new_comment.corps = "Le responsable de la demande a changé"
              new_comment.updated_on = v.updated_on
              new_comment.ingenieur_id = v.ingenieur_id
              new_comment.demande_id = d.id
              new_comment.severite_id = v.severite_id
              new_comment.statut_id = v.statut_id
              if v.ingenieur_id.nil?
                new_comment.identifiant_id = nil
              else
                new_comment.identifiant_id = Ingenieur.find(v.ingenieur_id).identifiant_id
              end
#               new_comment.save
            end

            #Si la sévérité a changé
            if old_version.severite_id != v.severite_id
              new_comment = Commentaire.new
              new_comment.created_on = v.created_on
              new_comment.corps = "La sévérité de la demande a changé"
              new_comment.updated_on = v.updated_on
              new_comment.ingenieur_id = v.ingenieur_id
              new_comment.demande_id = d.id
              new_comment.severite_id = v.severite_id
              new_comment.statut_id = v.statut_id
#               new_comment.save
            end
              #Dans les autres cas on ignore 
#               equal_no_state = true
#               attributes_no_state.each do |attr|
#                 equal_no_state = false and break if old_version.attributes[attr] != v.attributes[attr]
#               end
#               if equal_no_state #Pas de changement dans la demande. Ètrange...
#                 puts "Processing demande " << d.id.to_s << " (versions : " << d.versions.size.to_s << ")" if d.versions.size != 0
#                 if old_version.updated_on != v.updated_on
#                   #On ignore car l'erreur doit venir d'une édition sans modification de la demande
#                   puts "Erreur : Les deux versions #{old_version.version} et #{v.version} sont presques pareilles"
#                 else #Les deux versions sont rigoureusement identiques (modulo la version)
#                   #On ignore l'erreur vu qu'il n'y a aucunes modifications
#                   puts "Processing demande " << d.id.to_s << " (versions : " << d.versions.size.to_s << ")" if d.versions.size != 0
#                   puts "Erreur : Les deux versions #{old_version.version} et #{v.version} sont rigoureusement identiques"
#                 end
#               end
          else
            #Le commentaire qui a la date la plus proche de la date de création de notre version
            maybe_good_comment = d.commentaires.find(:first,
                                                     :conditions => { :prive => false },
                                                     :order => "ABS(UNIX_TIMESTAMP(created_on) - UNIX_TIMESTAMP('#{v.updated_on.strftime("%Y-%m-%d %H:%M:%S")}')) ASC")
            comments = 
            if maybe_good_comment.nil? #Boooo pas de commentaire :'(
#               puts "Processing demande " << d.id.to_s << " (versions : " << d.versions.size.to_s << ")" if d.versions.size != 0
              puts "Erreur : Changement d'état mais pas de commentaires ! (version " << v.version.to_s << ")"
              nb_erreurs += 1
            else
              delta = (v.updated_on - maybe_good_comment.created_on).abs
              if delta > 60.0
#                 puts "Processing demande " << d.id.to_s << " (versions : " << d.versions.size.to_s << ")" if d.versions.size != 0
                puts "Erreur : Demande " << d.id.to_s << ", Version " << v.version.to_s << ", Delta " << delta.to_s
                nb_erreurs += 1
              else
                maybe_good_comment.severite_id = v.severite_id if old_version.severite_id != v.severite_id
                maybe_good_comment.statut_id = v.statut_id if old_version.statut_id != v.statut_id
                maybe_good_comment.ingenieur_id = v.ingenieur_id if old_version.ingenieur_id != v.ingenieur_id
#                 maybe_good_comment.save
              end
            end
          end
        end
        old_version = v
      end
      end
    end
    puts "Erreurs : #{nb_erreurs}"
  end

  def self.down
  end
end
