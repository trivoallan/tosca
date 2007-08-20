#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'reporting_controller'

# Re-raise errors caught by the controller.
class ReportingController; def rescue_action(e) raise e end; end

class ReportingControllerTest < Test::Unit::TestCase
  def setup
    @controller = ReportingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login 'admin', 'admin'
  end

  def test_comex
    get :comex
    assert_response :success
    assert_template 'comex'
  end
  def test_comex_tableaux
    get :comex_resultat, { 
      :results => { :week_num => 33 },
      :clients => ['all'],
      :reporting => 'Voir le rapport pour cette semaine'
    }
    assert_response :success
    assert_template 'comex_resultat'
  end
  def test_comex_cns
    get :comex_resultat, {
      :results => { :week_num => 33 },
      :clients => ['all'],
      :cns => 'Voir l\'avancement du CNS'
    }
    assert_response :success
    assert_template 'comex_resultat'
  end
end
