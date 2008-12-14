require 'test_helper'

class HyperlinksControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hyperlinks)
  end

  def test_should_create_hyperlink
    get :new, :model_type => 'contribution', :model_id => 1
    assert_response :success
    form = select_form 'new_hyperlink'
    form.hyperlink.name = 'http://www.tosca-project.net'
    assert_difference('Hyperlink.count') { form.submit }

    assert_response :redirect
    assert_redirected_to(:controller => 'contributions',
                         :action => :show, :id => 1)
  end

  def test_should_show_hyperlink
    get :show, :id => hyperlinks(:hyperlink_00001).id
    assert_response :success
  end

  def test_should_update_hyperlink
    hyperlink = hyperlinks(:hyperlink_00001)
    get :edit, :id => hyperlink.id
    assert_response :success

    form = select_form "edit_hyperlink_#{hyperlink.id}"
    form.hyperlink.name = 'http://redmine.tosca-project.net'
    form.submit
    assert_response :redirect
    assert_redirected_to(:controller => hyperlink.model_type.pluralize,
                         :action => :show, :id => hyperlink.model_id)
  end

  def test_should_destroy_hyperlink
    hyperlink = hyperlinks(:hyperlink_00001)
    assert_difference('Hyperlink.count', -1) do
      delete :destroy, :id => hyperlink.id
    end

    assert_response :redirect
    assert_redirected_to(:controller => hyperlink.model_type.pluralize,
                         :action => :show, :id => hyperlink.model_id)
    hyperlink.save
  end

end
