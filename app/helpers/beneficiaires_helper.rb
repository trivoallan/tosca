#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BeneficiairesHelper

  def link_to_beneficiaires
    link_to 'Bénéficiaires', :action => 'list', :controller => 'beneficiaires'
  end
end
