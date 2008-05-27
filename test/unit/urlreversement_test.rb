require File.dirname(__FILE__) + '/../test_helper'

class UrlreversementTest < Test::Unit::TestCase
  fixtures :urlreversements, :contributions

  def test_to_strings
    check_strings Urlreversement
  end

  def test_attributes_presences
    u = Urlreversement.new
    assert !u.save
    assert u.errors.on(:valeur)
    assert u.errors.on(:contribution)

    contrib = contributions(:contribution_00001)
    u.update_attributes(:valeur => 'rubyonrails.org', :contribution => contrib)
    assert u.save
  end
end
