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
module CommentsHelper

  def display_history(comment, rule, contract)
    out = []
    if comment.user
      name = "<b>#{comment.user.name}</b>"
    else
      name = "<b>-</b>"
    end

    ingenieur = comment.ingenieur
    unless ingenieur.nil?
      if ingenieur.user_id == comment.user_id
        out << (_('This issue has been taken into account by %s.') % name )
      else
        out << (_('This issue has been assigned to %s by %s.') %
                [ "<b>#{ingenieur.name}</b>", name ])
      end
    end
    statut = comment.statut
    unless statut.nil?
      out << (_('This issue has been changed in %s by %s.') %
              [ "<b>#{statut.name}</b>", name ])
    end
    severite = comment.severite
    unless severite.nil?
      out << (_('This issue has been requalified in %s by %s.') %
              [ "<b>#{severite.name}</b>" , name ])
    end
    elapsed = comment.elapsed
    unless elapsed.nil? || elapsed == 0
      elapsed = rule.elapsed_formatted(elapsed, contract)
      out << (_('%s has been spent by %s on this issue.') %
              [ "<b>#{elapsed}</b>" , name ])
    end
    return nil if out.empty?
    '<div class="history">' << out.join('<br />') << '</div>'
  end


  def display_comment(c)
    result = ''
    result << c.text
    attachment = c.attachment
    unless attachment.blank? or attachment.file.blank?
      result << "<br /><br />#{StaticImage::folder} "
      result << link_to_file(attachment, :file).to_s
      result << " (#{file_size(attachment.file)})"
      result << link_to_file_redbox(attachment, :file).to_s
    end
    result
  end
end
