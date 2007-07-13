#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AccesController < ApplicationController
  skip_before_filter :login_required

  def refuse
  end


end

