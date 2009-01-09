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
require File.dirname(__FILE__) + '/../test_helper'

class ContributionTest < Test::Unit::TestCase
  fixtures :contributions

  def test_to_strings
    check_strings Contribution, :contributed_on_formatted, :summary
  end

  def test_content_columns
    assert !Contribution.content_columns.empty?
  end

  def test_fragments
    assert !Contribution.first(:order => :id).fragments.empty?
  end

  def test_delay
    delay = contributions(:contribution_0001).delay
    assert_instance_of Rational, delay
    # this one does not have a delay.
    delay = contributions(:contribution_0003).delay
    assert_instance_of Fixnum, delay
  end

  # This one cannot be included in "test_to_strings" since some contributions
  # does not have a closed_on date.
  def test_closed_on
    text = contributions(:contribution_0001).closed_on_formatted
    assert !text.blank?
  end
end
