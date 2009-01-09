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
class IssueSweeper < ActionController::Caching::Sweeper
  # There's a separate sweeper for Comments attached to an issue.
  # We can keep them separate, so we do :).
  # But take notes that those 2 others fragements are used :
  #  "#{record.id}/comments"
  #  "#{record.issue_id}/true/issues/front"
  #  "#{record.issue_id}/false/issues/front"

  observe Issue

  # If sweeper detects that an Issue was created or updated
  def after_save(record)
    expire_cache_for(record)
  end

  # If sweeper detects that an Issue was deleted call this
  def after_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    # Expire the left panel on a 'comment' action
    expire_fragments(record.fragments)
  end
end
