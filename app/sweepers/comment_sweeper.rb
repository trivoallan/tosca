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
class CommentSweeper < ActionController::Caching::Sweeper
  # All the cache used for comments are in the
  # 'comment' action of the 'issue' controller.
  observe Comment

  # If our sweeper detects that a Comment was created call this
  def after_save(comment)
    expire_cache_for(comment)
  end

  # If our sweeper detects that a Comment was deleted call this
  def after_destroy(comment)
    expire_cache_for(comment)
  end

  private
  def expire_cache_for(record)
    expire_fragments(record.fragments)
    # Comments are displayed in issue view
    expire_fragments(record.issue.fragments)
  end
end
