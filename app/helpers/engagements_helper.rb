#
# Copyright (c) 2006-2008 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
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
    out << '<tr><th>'
    out << _('Issue')
    out << '</th><th>'
    out << _('Severity')
    out << '</th><th>'
    out << _('Workaround')
    out << ' | '
    out << _('Correction')
    out << '</th></tr>'
    last_typeissue_id = 0
    last_severite_id = 0
    last_cycle = cycle('even', 'odd')
    selecteds = object_engagement.collect{|o| o.id }
    e = engagements.pop
    while (e) do
      out << '<tr><td colspan="5"><hr/></td></tr>' if e.typeissue_id != last_typeissue_id
      last_cycle = cycle('even', 'odd') if e.severite_id != last_severite_id
      out << "<tr class=\"#{last_cycle}\">"
      out << '<td>'
      if e.typeissue_id != last_typeissue_id
        out << "<strong>#{e.typeissue.name}</strong>"
        last_typeissue_id = e.typeissue_id
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
         name="contract[engagement_ids_#{last_typeissue_id}_#{last_severite_id}]">}
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
    titres = [_('Issue'), _('Severity'), _('Workaround'), _('Correction')]
    oldtypeissue = nil
    result << show_table(engagements, Engagement, titres) { |e|
      out = ''
      out << (oldtypeissue == e.typeissue_id ? '<td></td>' :
                "<td>#{e.typeissue.name}</td>" )
      out << "<td>#{e.severite.name}</td>"
      out << "<td>#{Time.in_words(e.contournement.days, true)}</td>"
      out << "<td>#{Time.in_words(e.correction.days, true)}</td>"
      if controller.controller_name == 'engagements'
        out << "#{link_to_actions_table e}"
      end
      oldtypeissue = e.typeissue_id
     out
    }
    result
  end
end
