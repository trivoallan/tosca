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
module MailHelper

  # met en forme du texte sur [width] colonnes
  # TODO : ne pas supprimer les saut de lignes (cf mails)
  def wrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

  def awrap(s, width=78)
    s.gsub!(/(.{1,#{width}})(\s+|\Z)/, ">\\1\n")
  end

end
