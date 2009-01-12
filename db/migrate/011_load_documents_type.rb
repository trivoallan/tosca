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
class LoadDocumentsType < ActiveRecord::Migration
  class Typedocument < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of documents
    return unless Typedocument.count == 0

    [ [ 'Bon de commande', "Bon des Unités d'Oeuvre commandés dans le cadre de marché Support Logiciel Libre." ],
      [ 'Compte-Rendu', 'Compte-Rendu des différentes réunions ayant eu lieu dans le cadre de votre contract.' ],
      [ 'Service', 'Documents qualités sur notre fonctionnement.' ],
      [ 'Veille', "Rapports de veille technologique, ciblant des sujets d'actualité pointus" ],
      [ 'Newsletter', "Lettre d'information mensuel sur votre périmètre logiciel." ],
      [ 'Audit', "Rapport d'audit sur des éléments logiciels ou matériels précis" ],
      [ 'Documentation', "Regroupe l'ensemble des livrables associés à un développement réalisé dans le cadre d'une Unité d'Oeuvre ou de votre contract." ]
    ].each{ |td|
      Typedocument.create(:nom => td.first, :description => td.last)
    }
  end

  def self.down
    Typedocument.all.each{ |td| td.destroy }
  end
end
