#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# This module contains all the stuff related to forms.
module FormsHelper

  PROMPT_SELECT = { :prompt => '» ' }

  ### FORMULAIRES ##################################################

  # Collection doit contenir des objects qui ont un 'id' et un 'nom'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # L'option :size permet une mise en colonne
  # Ex : hbtm_check_box( @logiciel.competences, @competences, 'competence_ids')
  def hbtm_check_box( objectcollection, collection, nom , options={})
    return '' if collection.nil?
    objectcollection ||= []
    out = '<table><tr>' and count = 1
    options_size = options[:size]
    length = collection.size
    nom_w3c = nom.gsub(/[^a-z1-9]+/i, '_')
    for donnee in collection
      out << "<td><input id=\"#{nom_w3c}_#{donnee.id}\" type=\"checkbox\" "
      out << "name=\"#{nom}[]\" value=\"#{donnee.id}\" "
      out << 'checked="checked" ' if objectcollection.include? donnee
      out << "/><label for=\"#{nom_w3c}_#{donnee.id}\">#{donnee}</label></td>"
      if options_size
        out << '</tr><tr>' if (count % options_size == 0) and length > count
        count += 1
      end
    end
    out << '</tr></table>'
    out << "<input type=\"hidden\" value=\"\" name=\"#{nom}[]\"/>"
  end

  # Collection doit contenir des objects qui ont un 'id' et un 'nom'
  # objectcollection contient le tableau des objects déjà présents
  # C'est la fonction to_s qui est utilisée pour le label
  # Ex : hbtm_radio_button( @logiciel.competences, @competences, 'competence_ids')
  def hbtm_radio_button( objectcollection, collection, nom )
    return '' if collection.nil?
    objectcollection ||= [] # TODO : changer la signature et faire le sed qui va bien
    out = ""
    for donnee in collection
      out << '<input type="radio" '
      out << "name=\"#{nom}[]\" value=\"#{donnee.id}\" "
      out << 'checked="checked" ' if objectcollection.include? donnee
      out << "/>#{donnee}"
    end
    out
  end

  # select_onchange(@clients, @current_client, 'client')
  # options
  # :width limite la taille du texte en nb de caractères
  # :title à afficher comme 1er élément de la liste (no value)
  # :onchange action si changement
  # :size hauteur du select
  def select_onchange(list, default, name, options = {})
    options[:title] ||= '» '
    options[:onchange] ||= 'this.form.submit();'
    options[:name] ||= name
    collected = [[options[:title], '']].concat(list.collect{|e| [e.nom, e.id] })
    default_value = (default.is_a?(Numeric) ? default : 0)
    select = options_for_select(collected, default_value)
    content_tag :select, select, options
  end

  def select_empty(list, default, name, options = {})
    title = [ '» ', '' ]
    options[:name] = name
    collected = list.collect{|e| [e.nom, e.id] }.unshift(title)
    select = options_for_select(collected, default.to_i)
    content_tag :select, select, options
  end

  # Fields est un tableau du formulaire, en 2 colonnes
  # mutualisé pour le formulaire et l'affichage
  # Les éléments doivent être affichable par to_s
  # si l'une des colonne est à nil, la ligne est fusionnée
  # Call it like this :
  # <% fields = [ lstm_text_field('Titre', 'identifiant', 'titre') ] %>
  # <%= show_table_form( fields) %>
  def show_table_form(fields, options = {})
    fields.compact!
    result = ''
    style = "class='#{options[:class]}'" if options.has_key? :class
    result << "<table #{style}>"
    fields.each { |f|
      title, field = f.first, f.last
      unless title.nil? and field.nil?
        result << '<tr>'
        if field.nil?
          result << '<td colspan="2">' << title << '</td>'
        elsif title.nil?
          result << '<td colspan="2">' << field << '</td>'
        else
          result << "<td>#{title}</td>"
          result << "<td>#{field}</td>"
        end
        result << '</tr>'
      end
    }
    result << '</table>'
  end

  # Display a quick form field to go to a ticket
  # TODO : use yield to include what we want in the form
  # Call it like :
  #  if session[:user] && session[:user].authorized?('demandes/index')
  #    out << form_tag(demandes_path)
  #    out <<  search_demande_field
  #    out << end_form_tag
  #  end
  def search_demande_field(options = {})
    text_field('numero', '', 'size' => 3)
  end
  alias_method :search_demande, :search_demande_field



  # write the label with the field.
  # heavily used in account with show_table_form
  # call it like this :
  # lstm_text_field('Téléphone', 'identifiant', 'telephone')
  def lstm_text_field(label, mmodel, field, options = {})
    [ "<label for=\"#{mmodel}_#{field}\">#{label}</label>",
      text_field(mmodel, field, options) ]
  end

  def lstm_password_field(label, model, field,
                          options = {:size => 16, :value => ''})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      password_field(model, field, options) ]
  end

  def lstm_text_area(label, model, field, options = {})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      text_area(model, field, options) ]
  end

  # Used for hiding field which will be displaye by ajax_*
  # call it like this :
  #   lstm_ajax_field('Bénéficiaire', :appel, :beneficiaires),
  def lstm_ajax_field(label, model, field)
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      "<div id=\"#{field}\"></div>" ]
  end

  # put a select field in a lazy way
  # call it like this :
  #  lstm_select_field('Contrat', :appel, :contrat, @contrats, :spinner => true)
  # options :
  #  * spinner : put the spinner for ajax stuff
  def lstm_select_field(label, model, field, collection, options = {})
    result = [ "<label for=\"#{model}_#{field}\">#{label}</label>",
               collection_select(model, field.to_s + '_id', collection,
                                 :id, :nom, PROMPT_SELECT)  ]
    result.last << ' ' + StaticImage::spinner if options.has_key? :spinner
    result
  end

  def lstm_datetime_field(label, model, field, options={})
    [ "<label for=\"#{model}_#{field}\">#{label}</label>",
      datetime_select(model, field) ]
  end

  def lstm_hline
    [ '<hr/>', nil ]
  end
end
