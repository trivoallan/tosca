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
    text = ''
    text << "##{demande.id} " if options[:show_id] 
    text << "#{icon_severite(demande)} " if options[:icon_severite] 
    text << "#{sum_up(demande.resume, 50)}"
    options = {:controller => 'demandes', 
               :action => 'comment', :id => demande.id}
    link_to text, options
  end

  # link to the 08000 wiki
  def link_to_help_new_request
    link_to('Déclaration d\'une demande', 
            "http://www.08000linux.com/wiki/index.php/D%C3%A9claration_demande")
  end
  
  # link to the 08000 wiki
  def link_to_howto_request
    link_to('Déroulement d\'une demande', 
            "http://www.08000linux.com/wiki/index.php/D%C3%A9roulement_demande")
  end


  # Affiche un résumé texte succint d'une demande
  # Utilisé par exemple pour les balise "alt" et "title"
  # on affiche '...' si le reste a afficher fait plus de 3 caracteres
  def sum_up( texte, limit=100, options ={:less => '...'})
    return texte unless (texte.is_a? String) && (limit.is_a? Numeric)
    out = ''
    if texte.size <= limit+3
      out << texte
    elsif
      out << texte[0..limit]
      out << options[:less]
    end
    out
  end

  # Décrit une demande
  def demande_description(d)
    return '-' unless d
   "#{d.typedemande.nom} (#{d.severite.nom}) : #{d.description}"
  end

  def display(donnee, column)
    case column
    when 'contournement','correction'
      display_jours donnee.send(column)
    else
      donnee.send(column)
    end
  end

  def icon_severite(d)
    desc = (d.respond_to?(:severite_nom) ? d.severite_nom : d.severite.nom)
    image_tag("severite_#{d.severite_id}.gif", :title => desc, :alt => desc )
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

  # used to display more nicely change to history table
  # use it like :
  # <%= display_history_changes(demande.ingenieur_id, old_ingenieur_id, Ingenieur) %>
  def display_history_changes(field, old_field, model)
    if field
      if old_field and old_field == field
        '<center></center>'
      else
        model.find(field).nom
      end
    else
      '<center>-</center>'
    end
  end

  # Used to call remote ajax action
  # Call it like :
  # <% options = { :update => 'demande_tab',
  #     :url => { :action => nil, :id => @demande.id },
  #     :before => "Element.show('spinner')",
  #     :success => "Element.hide('spinner')" } %>
  # <%= link_to_remote_tab('Description', 'ajax_description', options) %>
  def link_to_remote_tab(name, action_name, options)
    options[:url][:action] = action_name
    if (action_name != controller.action_name)
      link_to_remote name, options
    else
      link_to_remote name, options, :class => 'active'
    end
  end

end
