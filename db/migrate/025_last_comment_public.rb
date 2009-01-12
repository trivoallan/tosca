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
class LastCommentPublic < ActiveRecord::Migration

  class Demande < ActiveRecord::Base; end
  class Commentaire < ActiveRecord::Base; end

  def self.up
    Demande.all.each do |i|
      i.last_comment_id = Commentaire.first(
        :conditions => { :prive => false, :demande_id => i.id },
        :order_by => 'created_on DESC').id
      i.save!
    end
  end

  def self.down
    Demande.all.each do |i|
      i.last_comment_id = Commentaire.first(:conditions => { :demande_id => i.id },
        :order_by => 'created_on DESC').id
      i.save!
    end
  end
end
