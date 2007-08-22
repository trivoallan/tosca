#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class AccesController < ApplicationController

  # Seems silly, but it helps to reduce size of stack :)
  before_filter :login_required, :except => [:refuse]  

  def refuse
  end

end
