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
    options = { :order => 'contributions.updated_on DESC', 
      :include => [:logiciel,:etatreversement,:demandes], 
      :conditions => flash[:conditions] }

    contributions = Contribution.find(:all, options)
    stream_csv do |csv|
      csv << %w(id logiciel version etat résumé reversé cloturé délai)
      contributions.each do |c|
        csv << [ c.id, c.logiciel.nom, "'"+c.paquets.collect{|p| p.version}.join(','),
                 c.etatreversement.nom, c.synthese,
                 c.reverse_le_formatted, (c.clos ? c.cloture_le_formatted : ''), 
                 time_in_french_words(c.delai)
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


  # dirty hack to the end :)
  # c'est une copie de ceux du controlleur des demandes pour éviter les effets
  # de bord. Le premier n'influe pas sur le second
  # quoique ... TODO : on se repete entre ici et la méthode list.
  # TODO : c'est pas dry,  trouver une solution !
  SELECT_LIST = 'demandes.*, severites.nom as severites_nom, ' + 
    'logiciels.nom as logiciels_nom, id_benef.nom as beneficiaires_nom, ' +
    'typedemandes.nom as typedemandes_nom, clients.nom as clients_nom, ' +
    'id_inge.nom as ingenieurs_nom, statuts.nom as statuts_nom '
  JOINS_LIST = 'INNER JOIN severites ON severites.id=demandes.severite_id ' + 
    'INNER JOIN beneficiaires ON beneficiaires.id=demandes.beneficiaire_id '+
    'INNER JOIN identifiants id_benef ON id_benef.id=beneficiaires.identifiant_id '+
    'INNER JOIN clients ON clients.id = beneficiaires.client_id '+
    'LEFT OUTER JOIN ingenieurs ON ingenieurs.id = demandes.ingenieur_id ' + 
    'LEFT OUTER JOIN identifiants id_inge ON id_inge.id=ingenieurs.identifiant_id '+
    'INNER JOIN typedemandes ON typedemandes.id = demandes.typedemande_id ' + 
    'INNER JOIN statuts ON statuts.id = demandes.statut_id ' + 
    'INNER JOIN logiciels ON logiciels.id = demandes.logiciel_id '

  # return the contents of a demande in a table in CSV format
  def demandes
    options = { :order => 'updated_on DESC', :conditions => flash[:conditions],
      :select => SELECT_LIST, :joins => JOINS_LIST }
    demandes = Demande.find(:all, options)
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
                d.logiciels_nom, 
                (d.beneficiaires_nom), 
                (d.clients_nom), 
                (d.ingenieurs_nom), 
                d.severites_nom, 
                d.reproduit, 
                'version?', 
                d.created_on_formatted, 
                'socle?', 
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
