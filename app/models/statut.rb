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
  N_('Cancelled') #8     Annulée        #
  #######################################
  
  SELECT = 'statuts.id, statuts.nom '

  def possible(recipient = nil)
    search = 
      if recipient
        return [] unless id == 3
        'id IN (6,7,8)'
      else
        case id
        when 1 then 'id IN (2)'
        when 2 then 'id IN (4,3,8)'
        when 3 then 'id IN (2,5,6,7,8)'
        when 4 then 'id IN (3)'
        when 5 then 'id IN (3)'
        when 6 then 'id IN (7)'
        when 7 then 'id IN (2)'
        when 8 then 'id IN (2)'
        end 
      end
    Statut.find(:all, :select => SELECT, :conditions => search)
  end

end
