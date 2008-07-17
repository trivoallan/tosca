module EngagementsHelper


  def link_to_new_engagement()
    link_to(image_create('engagement'), new_engagement_path)
  end

  # Display form for choosing engagements;
  # They MUST have been sort by the Engagement::ORDER options.
  # Call it like this :
  #   show_form_engagements(@contract.engagements, @engagements, 'contract[engagement_ids]' )
  # TODO : habiller et mettre des bordures pour que ca se distingue du reste
  #  cf /contracts/new pour le voir
  # TODO : a partial should be better
  def show_form_engagements(object_engagement, engagements, name)
    out = '<table>'
    out << '<tr><th>Demande</th><th>Sévérité</th>'
    out << '<th>Contournement | Correction</th></tr>'
    last_typedemande_id = 0
    last_severite_id = 0
    last_cycle = cycle('even', 'odd')
    selecteds = object_engagement.collect{|o| o.id }
    e = engagements.pop
    while (e) do
      out << '<tr><td colspan="5"><hr/></td></tr>' if e.typedemande_id != last_typedemande_id
      last_cycle = cycle('even', 'odd') if e.severite_id != last_severite_id
      out << "<tr class=\"#{last_cycle}\">"
      out << '<td>'
      if e.typedemande_id != last_typedemande_id
        out << "<strong>#{e.typedemande.name}</strong>"
        last_typedemande_id = e.typedemande_id
      end
      out << '</td><td>'
      if e.severite_id != last_severite_id
        out << e.severite.name
        last_severite_id = e.severite_id
      end
      out << '</td><td>'
      severities = []
      severities.push ['» ',0]
      # selecteds = []
      out << %Q{<select id="contract_engagement_ids"
         name="contract[engagement_ids_#{last_typedemande_id}_#{last_severite_id}]">}
      while (e) do
        workaround = Time.in_words(e.contournement.days, true)
        correction = Time.in_words(e.correction.days, true)
        workaround = _('None') if workaround == '-'
        correction = _('None') if correction == '-'
        severities.push ["#{workaround} | #{correction}", e.id]
        break if engagements.empty? || (engagements.last.severite_id != last_severite_id)
        e = engagements.pop
      end
      out << options_for_select(severities, selecteds)
      out << '</select>'
      out << '</td></tr>'
      e = engagements.pop
    end
    out << '</table'
  end

  def show_table_engagements(engagements)
    result = ''
    titres = ['Demande','Sévérité','Contournement','Correction']
    oldtypedemande = nil
    result << show_table(engagements, Engagement, titres) { |e|
      out = ''
      out << (oldtypedemande == e.typedemande_id ? '<td></td>' :
                "<td>#{e.typedemande.name}</td>" )
      out << "<td>#{e.severite.name}</td>"
      out << "<td>#{Time.in_words(e.contournement.days, true)}</td>"
      out << "<td>#{Time.in_words(e.correction.days, true)}</td>"
      if controller.controller_name == 'engagements'
        out << "#{link_to_actions_table e}"
      end
      oldtypedemande = e.typedemande_id
     out
    }
    result
  end
end
