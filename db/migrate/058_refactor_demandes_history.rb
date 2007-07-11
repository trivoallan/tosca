class RefactorDemandesHistory < ActiveRecord::Migration
  def self.up
#     add_column(:commentaires, :severite_id, :integer, :null => true)
#     add_column(:commentaires, :statut_id, :integer, :null => true)
#     add_column(:commentaires, :ingenieur_id, :integer, :null => true)

#     add_index(:commentaires, :severite_id)
#     add_index(:commentaires, :statut_id)
#     add_index(:commentaires, :ingenieur_id)

    #Nom des attributs d'une demande qui peuvent raisonnablement être égaux d'une version à l'autre
    attributes_equal = %w(created_on logiciel_id ingenieur_id severite_id description resume beneficiaire_id statut_id mail_cc socle_id typedemande_id contribution_id)
    #Nom des attributs d'une demande qui ne devraient vraiment pas être égaux d'une version à l'autre
    attributes_error = %w(updated_on)
    old_demande_id = 0
    nb_erreurs = 0
    Demande.find(:all, :order => 'id ASC').each do |d|
      old_version = nil
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
          if v.ingenieur_id.nil?
            #Demande déposée par un bénéficaire
            new_comment.identifiant_id = Beneficiaire.find(v.beneficiaire_id).identifiant_id
          else
            #Demande déposée par un ingé
            new_comment.identifiant_id = Ingenieur.find(v.ingenieur_id).identifiant_id
          end
#           puts "Création nouveau commentaire pour demande #{d.id}"
#           new_comment.save
        else
          #Le commentaire qui a la date la plus proche de la date de création de notre version
          maybe_good_comment = d.commentaires.find(:first,
                                                   :conditions => { :prive => false },
                                                   :order => "ABS(UNIX_TIMESTAMP(created_on) - UNIX_TIMESTAMP('#{v.updated_on.strftime("%Y-%m-%d %H:%M:%S")}')) ASC")
          next if maybe_good_comment.nil? #Boooo pas de commentaire :'(

          #On regarde si la version courante est raisonnablement la même que la version actuelle
          equal = true
          attributes_equal.each do |attr|
            equal = false and break if old_version.attributes[attr] != v.attributes[attr]
          end
          if equal
#             puts "Demande #{d.id}, version #{old_version.version} pareil à #{v.version}"
          else
            equal = true
            attributes_error .each do |attr|
              equal = false and break if old_version.attributes[attr] != v.attributes[attr]
            end
            if equal
#               puts "Demande #{d.id}, version #{old_version.version} pareil à #{v.version}"
            else
              #Si le temps est supérieur à 10 secondes
              delta = (v.updated_on - maybe_good_comment.created_on).abs
              if delta > 10.0
#                 puts "Processing demande " << d.id.to_s << " (versions : " << d.versions.size.to_s << ")" if d.versions.size != 0
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
  end

  def self.down
  end
end
