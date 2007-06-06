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
    options = { :order => 'contributions.reverse_le ASC', 
      :include => [:logiciel,:etatreversement,:demandes], 
      :conditions => flash[:conditions] }

    contributions = Contribution.find(:all, options)
    stream_csv do |csv|
      csv << %w(id type logiciel version etat résumé signalé cloturé délai)
      contributions.each do |c|
        csv << [ c.id, c.typecontribution.nom, c.logiciel.nom, 
                 "'"+c.version.to_s, c.etatreversement.nom, c.synthese,
                 c.reverse_le_formatted, (c.clos ? c.cloture_le_formatted : ''), 
                 Lstm.time_in_french_words(c.delai)
               ]
      end
    end
  end

  # return the contents of identifiants in a table in CSV format
  def identifiants
    options = { :order => 'identifiants.login', :include => 
      [:beneficiaire,:ingenieur,:roles], :conditions => flash[:conditions] }

    identifiants = Identifiant.find(:all, options)
    stream_csv do |csv|
      csv << ["id", "login", "nom", "e-mail", "telephone", 
              "(client)", 
              "roles" ]
      identifiants.each do |i|
        csv << [ i.id, i.login, i.nom, i.email, i.telephone,
                (i.beneficiaire.client.nom if i.beneficiaire), 
                i.roles.join(', ') ].compact
      end
    end
  end

  def appels
    options = { :order => 'appels.debut', :include => 
      [:beneficiaire,:ingenieur,:contrat,:demande], 
      :conditions => flash[:conditions] }
    appels = Appel.find(:all, options)
    stream_csv do |csv|
      csv << ['Contrat','Responsable','Bénéficiaire','Appel','Fin de l\'appel' ]
      appels.each { |a|
        csv << [ a.contrat.nom, a.ingenieur.nom, 
                 (a.beneficiaire ? a.beneficiaire.nom : '-'),
                 a.debut, a.fin ]
      }
    end
  end




  # return the contents of a demande in a table in CSV format
  def demandes
    options = { :order => 'updated_on DESC', :conditions => flash[:conditions],
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    demandes = Demande.find(:all, options)
    stream_csv do |csv|
      csv << ['id', 
              'logiciel', 
              'bénéficiaire', 
              'client', 
              'responsable', 
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
        paquets = d.paquets
        if paquets and paquets.size > 0
          if paquets.size == 1
            version = "'#{paquets.first.version}"
          else
            version = paquets.collect {|p| p.version}.join("\n")
          end
        else
          version = '-'
        end

        csv << [d.id, 
                d.logiciels_nom, 
                (d.beneficiaires_nom), 
                (d.clients_nom), 
                (d.ingenieurs_nom), 
                d.severites_nom, 
                d.reproduit, 
                version,
                d.created_on_formatted, 
                (d.socle ? d.socle.nom : '-'), 
                d.updated_on_formatted, 
                d.resume, 
                d.statuts_nom,              
                d.typedemandes_nom ]
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
    # output = ''
    # csv = FasterCSV.new(output, :row_sep => "\r\n", :col_sep => ";") 
    # send_data 'toto', :type => 'text/csv', :filename => filename
      render :text => Proc.new { |response, output|
        csv = FasterCSV.new(output, :row_sep => "\r\n", :col_sep => ";") 
        yield csv
      }, :layout => false
  end

end
