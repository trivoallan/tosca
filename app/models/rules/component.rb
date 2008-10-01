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
#########################################
# The Rules' classes MUST stay coherent #
#########################################
class Rules::Component < ActiveRecord::Base

  def elapsed_on_create
    0
  end

  def elapsed_formatted(value, contract)
    Time.in_words(value, contract.interval)
  end

  # Call it like this :
  # rule.compute_between(last_status_comment, self, contract)
  # It will update "self.elapsed" with the elapsed time between
  # the 2 comments which MUST change the status
  def compute_between(last, current, contract)
    return 0 unless last.statut_id != 0 && current.statut_id != 0
    return 0 unless Statut::Running.include? last.statut_id
    Time.working_diff(last.created_on, current.created_on,
                      contract.opening_time,
                      contract.closing_time)
  end

  def short_description
    if max == -1
      _('Illimited offer on all components')
    else
      _('Illimited offer on a maximum of %d components') % max
    end
  end

end
