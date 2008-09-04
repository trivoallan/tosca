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
class Statut < ActiveRecord::Base
  has_many :demandes

  #######################################
  N_('Submitted') #1  	Enregistrée     #
  N_('Active')    #2	Prise en compte #
  N_('Suspended') #3	Suspendue       #
  N_('Analysed')  #4	Analysée        #
  N_('Bypassed')  #5 	Contournée      #
  N_('Fixed')     #6	Corrigée        #
  N_('Closed')    #7	Clôturée        #
  N_('Cancelled') #8    Annulée         #
  #######################################

  # used in lib/comex_reporting and models/demande.rb
  # Please be EXTREMELY cautious if you touch them.
  OPENED = [ 1, 2, 3, 4, 5 ] # We need to work on it
  CLOSED = [ 6, 7, 8 ] # The time count is now less/not important

  NEED_COMMENT = [ 3, 4, 8 ] #These status need a comment if you use them, Suspended, Analysed, Cancelled
  
  Running = [ 1, 2, 4, 5 ] # Chrono is up

  # We do not want in any case a modification on those ids
  [ OPENED, CLOSED ].each do |xs|
    xs.each{|x| x.freeze}.freeze
  end

  Active = 2
  Bypassed = 5
  Fixed = 6
  
  # Give possible status for next step of a request
  # It follows scheme on the 08000linux wiki
  # Even recipient can change some status,
  # when it's for closed or cancelled a request.
  # TODO : allow dynamic editing of this logic in Web Browser
  def possible(recipient = nil)
    search =
      if recipient
        return [] unless id == 3 || id == 2
        'id IN (6,7,8)'
      else
        case id
        when 1 then 'id IN (2)'            # Submitted -> Active
        when 2 then 'id IN (3,4,5,6,7,8)'  # Active -> Suspended, Analysed, Bypassed, Fixed, Closed, Cancelled
        when 3 then 'id IN (2,4,5,6,7,8)'  # Suspended -> Active, Analysed, Bypassed, Fixed, Closed, Cancelled
        when 4 then 'id IN (3)'            # Analysed -> Suspended
        when 5 then 'id IN (3,2)'          # Bypassed -> Suspended, Active
        when 6 then 'id IN (7,2)'          # Fixed -> Closed, Active
        when 7 then 'id IN (2)'            # Closed -> Active
        when 8 then 'id IN (2)'            # Cancelled -> Active
        end
      end
    Statut.find_select(:conditions => search, :order => 'statuts.id')
  end

end
