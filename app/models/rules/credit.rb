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
class Rules::Credit < ActiveRecord::Base

  def elapsed_on_create
    1
  end

  def elapsed_formatted(value, contract)
    n_('%d time-credit', '%d time-credits', value) % value
  end

  # It's called like this :
  # rule.compute_elapsed_between(last_status_comment, self)
  # It won't do anything : the credit spent is filled manually, not computed
  def compute_between(last, current, contract)
    current.elapsed
  end

  def short_description
    if max == -1
      _('Illimited number of tickets of %s') %
        Time.in_words(time.hours)
    else
      _('Up to %d tickets of %s') %
        [ max, Time.in_words(time.hours) ]
    end
  end

end
