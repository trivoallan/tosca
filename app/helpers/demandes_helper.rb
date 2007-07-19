#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module DemandesHelper

  # Display a link to a demand
  # Options
  #  * :pre_text (deprecated) display before
  #  * :show_id display the id
  #  * :icon_severite display severity icon
  def link_to_demande(demande, options={})
    return '-' unless demande
    text = options[:text]
    if text.nil?
      limit = options[:limit] || 50
      text = ''
      text << "##{demande.id} " if options[:show_id]
      text << "#{icon_severite(demande)} " if options[:icon_severite]
      text << truncate(demande.resume, limit)
    end
    link_to text, comment_demande_url(:id => demande.id)
  end

  # Link to the inline help to post a request
  def public_link_to_help_new_request
    public_link_to('Déclaration d\'une demande',
            "http://www.08000linux.com/wiki/index.php/D%C3%A9claration_demande")
  end

  # Link to the the inline help about life cycle of a demand
  def public_link_to_howto_request
    public_link_to('Déroulement d\'une demande',
            "http://www.08000linux.com/wiki/index.php/D%C3%A9roulement_demande")
  end

  #Link to the inline help about the differents states of a demand
  def public_link_to_help_demand_state
        public_link_to('Explication détaillée des statuts',
          'http://www.08000linux.com/wiki/index.php/%C3%89tats_demande')
  end


  # Description of a demand
  # DEPRECATED : use instance method for 'to_s' Demande
  def demande_description(d)
    return '-' unless d
    "#{d.typedemande.nom} (#{d.severite.nom}) : #{d.description}"
  end

  # TODO : explain what does this function
  # TODO : teach the author how to make it understandable
  # TODO : give an example
  # TODO : think about replacing case/when by if/else
  def display(donnee, column)
    case column
    when 'contournement','correction'
      display_jours donnee.send(column)
    else
      donnee.send(column)
    end
  end

  #Display the short way of severity
  # TODO : take the id and make the case on the id
  def short_severite(d)
    case d.severite_id
    when 1 then 'Bl'
    when 2 then 'Ma'
    when 3 then 'mi'
    when 4 then 'so'
    else
      'wtf'
    end
  end

  def render_table(options)
    render :partial => "report_table", :locals => options
  end

  def render_detail(options)
    render :partial => "report_detail", :locals => options
  end

  # TODO : modifier le model : ajouter champs type demande aux engagements
  # TODO : prendre en compte le type de la demande !!!

  def display_engagement_contournement(demande, paquet)
    engagement = demande.engagement(paquet.contrat_id)
    display_jours(engagement.contournement)
  end

  def display_engagement_correction(demande, paquet)
    engagement = demande.engagement(paquet.contrat_id)
    display_jours(engagement.correction)
  end

  # Display (open) time spent to now
  # TODO : rename it 'display_temps_ecoule'
  def display_tempsecoule(demande)
    "TODO" #distance_of_time_in_french_words compute_delai4paquet @demande
  end

  # Display more nicely change to history table
  # Use it like :
  #  <%= display_history_changes(demande.ingenieur_id, old_ingenieur_id, Ingenieur) %>
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
  #  <% options = { :update => 'demande_tab',
  #     :url => { :action => nil, :id => @demande.id },
  #     :before => "Element.show('spinner')",
  #     :success => "Element.hide('spinner')" } %>
  #  <%= link_to_remote_tab('Description', 'ajax_description', options) %>
  def link_to_remote_tab(name, action_name, options)
    options[:url][:action] = action_name
    if (action_name != controller.action_name)
      link_to_remote name, options
    else
      link_to_remote name, options, :class => 'active'
    end
  end

  def link_to_new_request
    options = new_demande_url
    link_to(image_create(_('New request')), options, LinksHelper::NO_HOVER)
  end


  # Link to access a ticket
  def link_to_comment(ar)
      link_to image_view, comment_demande_path(ar), { :class => 'nobackground' }
  end

  #usage : link_to_help('state') to link to the help page
  # for states demand
  def link_to_help( topic)
      link_to image_help,
        'http://www.08000linux.com/wiki/index.php/%C3%89tats_demande',
        { :class => 'nobackground' }
  end

  def link_to_delete_contribution( demand_id )
    link_to _('Unlink the contribution') ,delete_contribution_demande_path(demand_id)
  end



  # Display a css bar for graphic representation of a ticket timeline
  # Options
  #  * (no options yet)
  # Need adequat CSS stylesheet
  def show_cns_bar(demande, options={})
    #done, limit = 0, 100
    return '' unless demande.is_a?(Demande)
    done = demande.temps_correction
    limit = demande.delais_correction
    return '' unless done.is_a?(Numeric) && limit.is_a?(Numeric) && done <= limit

    out = ''
    progress = (100*(done.to_f / limit.to_f)).round
    remains = (100 - progress)
    out << '<span class="progress-border">'
    #out << '  <div class="progress-contournement tooltip" style="width: 20%;" title="20% (0/2)  Low Priority "> </div>'
    out << '  <div class="progress-correction tooltip" style="width: '+progress.to_s+'%;" title="'+progress.to_s+'%  écoulé"> </div>'
    out << '  <div class="progress-restant tooltip" style="width: '+remains.to_s+'%;" title="'+remains.to_s+'%  restant"> </div>'
    out << '</span>'
  end


  # TODO : beaucoup trop de copier coller, c'est honteux !
  # TODO/MLO : me taper sur les doigts et faire une version propre
  # begining of factorisation in logiciels_helper
  AJAX_CALL = PagesHelper::AJAX_OPTIONS.dup.update(:url => '../demandes/index')
  def remote_link_to_active_request
    js_call = "document.forms['filters'].active.value=1; #{remote_function(AJAX_CALL)}"
    link_to_function(_('active requests'), js_call,
                     _('show the requests that are waiting to be processed'))
  end

  def remote_link_to_dead_request
    js_call = "document.forms['filters'].active.value=-1; #{remote_function(AJAX_CALL)}"
    link_to_function(_('finished requests'), js_call,
                     _('show the requests that were processed'))
  end

  def remote_link_to_all_request
    js_call = "document.forms['filters'].active.value=0; #{remote_function(AJAX_CALL)}"
    link_to_function(_('all the requests'), js_call,
                     _('show all the requests'))
  end

  #usage : <tr <%= tr_attributes("../demandes/comment/#{demand.id}")%> >
  def tr_attributes(href)
   return "class=\"#{cycle('pair', 'impair')}\" " <<
      "onclick=\"window.location.href='#{href}'\""
  end


end
