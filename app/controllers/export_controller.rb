#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

require 'fastercsv'
# generate CSV files for download
# send formatted output directly to the HTTP response
# source : http://wiki.rubyonrails.org/rails/pages/HowtoExportDataAsCSV
class ExportController < ApplicationController

  # return the contents of identifiants in a table in CSV format
  def contributions
    contributions = Contribution.find(:all)
    stream_csv do |csv|
      csv << %w(id logiciel version etat description reversé cloturé délai)
      contributions.each do |c|
        csv << [ c.id, c.logiciel.nom, c.paquets.collect{|p| p.version}.join(','),
                 c.etatreversement.nom, c.description_fonctionnelle,
                 c.reverse_le_formatted, c.cloture_le_formatted, c.delai
               ]
      end
    end
  end

  # return the contents of identifiants in a table in CSV format
  def identifiants
    identifiants = Identifiant.find(:all)
    stream_csv do |csv|
      csv << ["id", "login", "nom", "e-mail", "telephone", 
              "(client)", 
              "roles" ]
      identifiants.each do |i|
        csv << [i.id, i.login, i.nom, i.email, i.telephone,
                (i.beneficiaire.client.nom if i.beneficiaire), 
                i.roles.join(', ') ].compact
      end
    end
  end

  # return the contents of a demande in a table in CSV format
  def demandes
    demandes = Demande.find(:all)
    stream_csv do |csv|
      csv << ['id', 
              'logiciel', 
              'bénéficiaire', 
              'client', 
              'ingénieur', 
              'sévérité', 
              'reproductible', 
              'version', 
              'date de soumission', 
              'plate-forme', 
              'mis-à-jour', 
              'résumé', 
              'statut', 
              'type' ]
      demandes.each do |d|
        csv << [d.id, 
                d.logiciel.nom, 
                (d.beneficiaire.identifiant.nom if d.beneficiaire), 
                (d.beneficiaire.client.nom if d.beneficiaire), 
                (d.ingenieur.identifiant.nom if d.ingenieur), 
                d.severite.nom, 
                d.reproduit, 
                'version?', 
                d.created_on_formatted, 
                'socle?', 
                d.updated_on_formatted, 
                d.resume, 
                d.statut.nom,              
                d.typedemande.nom ]
      end
      #csv << ['id', 'type', 'statut', 'resume']
      #csv << [demande.id, demande.typedemande.nom, demande.statut.nom, demande.resume]
    end 
  end

  private
  
  def stream_csv
    prefix = ( @beneficiaire ? @beneficiaire.client.nom : 'OSSA' )
    suffix = Time.now.strftime('%d_%m_%Y')
    filename = [ prefix, params[:action], suffix].join('_') + '.csv'

     #this is required if you want this to work with IE        
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers['Content-type'] = 'text/plain' 
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
       headers['Expires'] = "0" 
     else
       headers["Content-type"] ||= 'text/csv'
       headers['Pragma'] = 'public'
       headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
     end

     render :text => Proc.new { |response, output|
       csv = FasterCSV.new(output, :row_sep => "\r\n", :col_sep => ";") 
       yield csv
     }, :layout => false
  end

end
