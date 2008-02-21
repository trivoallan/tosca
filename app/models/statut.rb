#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
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
  OPENED = [ 1, 2, 3, 4, 5] # We need to work on it
  CLOSED = [ 6, 7, 8] # The time count is now less/not important

  WithoutChrono = [ 3, 6, 7, 8 ]

  # We do not want in any case a modification on those ids
  [ OPENED, CLOSED ].each do |xs|
    xs.each{|x| x.freeze}.freeze
  end


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
        when 1 then 'id IN (2)'
        when 2 then 'id IN (4,3,6,7,8)'
        when 3 then 'id IN (2,5,6,7,8)'
        when 4 then 'id IN (3)'
        when 5 then 'id IN (3)'
        when 6 then 'id IN (7,2)'
        when 7 then 'id IN (2)'
        when 8 then 'id IN (2)'
        end
      end
    Statut.find_select(:conditions => search, :order => 'statuts.id')
  end

end
