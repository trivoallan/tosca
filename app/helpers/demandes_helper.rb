#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module DemandesHelper

  # lien vers une demande : affiche le nom de la demande
  # options
  # :pre_text à afficher avant le nom
  # :show_id affiche l'id à la place du nom de la demande
  def link_to_demande(demande, options={})
    return 'N/A' unless demande
    nom = sum_up(demande.resume, 50)
    alt = sum_up(demande.description)
    link = ''
    link << "#{options[:pre_text]} " if options[:pre_text]
    link << ( options[:show_id] ? "##{demande.id} " : nom )
    link_to link,{:controller => 'demandes',
      :action => 'comment', :id => demande.id}, { :alt => alt, :title => alt }

  end

  def display(donnee, column)
    case column
    when 'contournement','correction'
      display_jours donnee.send(column)
    else
      donnee.send(column)
    end
  end

  def render_table(options)
    render :partial => "report_table", :locals => options
  end

  def render_detail(options)
    render :partial => "report_detail", :locals => options
  end

  # todo : modifier le model : ajouter champs type demande aux engagements
  # todo : prendre en compte le type de la demande !!!

  def display_engagement_contournement(demande, paquet)
    engagement = demande.engagement(paquet.contrat_id)
    display_jours(engagement.contournement)
  end

  def display_engagement_correction(demande, paquet)
    engagement = demande.engagement(paquet.contrat_id)
    display_jours(engagement.correction) 
  end

  def display_tempsecoule(demande)
    "TODO" #distance_of_time_in_french_words compute_delai4paquet @demande
  end
  
end
