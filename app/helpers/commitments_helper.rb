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
module CommitmentsHelper


  def link_to_new_commitment()
    link_to(image_create('commitment'), new_commitment_path)
  end

  # Display form for choosing commitments;
  # They MUST have been sort by the Commitment::ORDER options.
  # Call it like this :
  #   show_form_commitments(@contract.commitments, @commitments, 'contract[commitment_ids]' )
  # TODO : habiller et mettre des bordures pour que ca se distingue du reste
  #  cf /contracts/new pour le voir
  # TODO : a partial should be better
  def show_form_commitments(object_commitment, commitments, name)
    out = '<table>'
    out << '<tr><th>'
    out << _('Request')
    out << '</th><th>'
    out << _('Severity')
    out << '</th><th>'
    out << _('Workaround')
    out << ' | ' 
    out << _('Correction')
    out << '</th></tr>'
    last_typedemande_id = 0
    last_severite_id = 0
    last_cycle = cycle('even', 'odd')
    selecteds = object_commitment.collect{|o| o.id }
    e = commitments.pop
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
      out << %Q{<select id="contract_commitment_ids"
         name="contract[commitment_ids_#{last_typedemande_id}_#{last_severite_id}]">}
      while (e) do
        workaround = Time.in_words(e.workaround.days, true)
        correction = Time.in_words(e.correction.days, true)
        workaround = _('None') if workaround == '-'
        correction = _('None') if correction == '-'
        severities.push ["#{workaround} | #{correction}", e.id]
        break if commitments.empty? || (commitments.last.severite_id != last_severite_id)
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
    titres = [_('Request'), _('Severity'), _('Workaround'), _('Correction')]
    oldtypedemande = nil
    result << show_table(commitments, Commitment, titres) { |e|
      out = ''
      out << (oldtypedemande == e.typedemande_id ? '<td></td>' :
                "<td>#{e.typedemande.name}</td>" )
      out << "<td>#{e.severite.name}</td>"
      out << "<td>#{Time.in_words(e.workaround.days, true)}</td>"
      out << "<td>#{Time.in_words(e.correction.days, true)}</td>"
      if controller.controller_name == 'commitments'
        out << "#{link_to_actions_table e}"
      end
      oldtypedemande = e.typedemande_id
     out
    }
    result
  end
end
