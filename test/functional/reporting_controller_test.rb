require File.dirname(__FILE__) + '/../test_helper'

class ReportingControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

=begin
  # deactivated for now

  def test_comex_cns
    get :comex_resultat, {
      :results => { :week_num => 33 },
      :clients => ['all'],
      :cns => 'Voir l\'avancement du CNS'
    }
    assert_response :success
    assert_template 'comex_resultat'
  end
=end

end
