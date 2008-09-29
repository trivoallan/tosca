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
class Contribution < ActiveRecord::Base
  has_one :issue
  has_many :urlreversements

  belongs_to :typecontribution
  belongs_to :etatreversement
  belongs_to :software
  belongs_to :ingenieur

  belongs_to :affected_version, :class_name => "Version"
  belongs_to :fixed_version, :class_name => "Version"

  file_column :patch, :fix_file_extensions => nil

  validates_length_of :name, :within => 3..100
  validates_presence_of :software,
    :warn => _('You have to specify a software.')

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }
  end

  def to_s
    return name unless patch
    index = patch.rindex('/')+ 1
    patch[index..-1]
  end

  def fragments
    [ %r{contributions/select_(\d*|all)} ]
  end

  def summary
    out = ''
    out << typecontribution.name + _(' on ') if typecontribution
    out << software.name
    out << " #{affected_version}" if affected_version
    out
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def contributed_on_formatted
    contributed_on = read_attribute(:contributed_on)
    return '' unless contributed_on
    display_time contributed_on
  end

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def closed_on_formatted
    closed_on = read_attribute(:closed_on)
    return '' unless closed_on
    display_time closed_on
  end

  # délai (en secondes) entre la déclaration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2day(delai)
  def delay
    if closed_on? and contributed_on?
      (closed_on - contributed_on)
    else
      -1
    end
  end
  
  # Fake fields, used to prettify _form WUI
  def reverse; contributed_on?; end
  def clos; closed_on?; end
  def clos=(fake); end
  def reverse=(fake); end

end
