#
# Copyright (c) 2006-2009 Linagora
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
module CommitmentsHelper

  def link_to_new_commitment
    link_to(image_create('commitment'), new_commitment_path)
  end

  # Display form for choosing commitments;
  # They MUST have been sort by the Commitment::ORDER options.
  # Call it like this :
  #   show_form_commitments(@contract.commitments, @commitments)
  # TODO : habiller et mettre des bordures pour que ca se distingue du reste
  #  cf /contracts/new pour le voir
  # TODO : a partial should be better
  def show_form_commitments(object_commitment, commitments)
    out = '<table class="full">'
    out << '<tr><th>'
    out << _('Type')
    out << '</th><th>'
    out << _('Severity')
    out << '</th><th>'
    out << _('Workaround')
    out << ' | '
    out << _('Correction')
    out << '</th></tr>'
    last_issuetype_id = 0
    last_severity_id = 0
    last_cycle = cycle('even', 'odd')
    selecteds = object_commitment.collect{|o| o.id }
    e = commitments.pop
    while (e) do
      out << '<tr><td colspan="5"><hr/></td></tr>' if e.issuetype_id != last_issuetype_id
      last_cycle = cycle('even', 'odd') if e.severity_id != last_severity_id
      out << "<tr class=\"#{last_cycle}\">"
      out << '<td>'
      if e.issuetype_id != last_issuetype_id
        out << "<strong>#{e.issuetype.name}</strong>"
        last_issuetype_id = e.issuetype_id
      end
      out << '</td><td>'
      if e.severity_id != last_severity_id
        out << e.severity.name
        last_severity_id = e.severity_id
      end
      out << '</td><td>'
      severities = []
      severities.push ['» ',0]
      # selecteds = []
      out << %Q{<select id="contract_commitment_ids"
         name="contract[commitment_ids_#{last_issuetype_id}_#{last_severity_id}]">}
      while (e) do
        workaround = Time.in_words(e.workaround.days, true)
        correction = Time.in_words(e.correction.days, true)
        workaround = _('None') if workaround == '-'
        correction = _('None') if correction == '-'
        severities.push ["#{workaround} | #{correction}", e.id]
        break if commitments.empty? || (commitments.last.severity_id != last_severity_id)
        e = commitments.pop
      end
      out << options_for_select(severities, selecteds)
      out << '</select>'
      out << '</td></tr>'
      e = commitments.pop
    end
    out << '</table>'
  end

  def show_table_commitments(commitments)
    result = ''
    titres = [_('Issue'), _('Severity'), _('Workaround'), _('Correction')]
    oldissuetype = nil
    result << show_table(commitments, Commitment, titres) { |e|
      out = ''
      out << (oldissuetype == e.issuetype_id ? '<td></td>' :
                "<td>#{e.issuetype.name}</td>" )
      out << "<td>#{e.severity.name}</td>"
      out << "<td>#{Time.in_words(e.workaround.days, true)}</td>"
      out << "<td>#{Time.in_words(e.correction.days, true)}</td>"
      if controller.controller_name == 'commitments'
        out << "#{link_to_actions_table e}"
      end
      oldissuetype = e.issuetype_id
     out
    }
    result
  end
end
