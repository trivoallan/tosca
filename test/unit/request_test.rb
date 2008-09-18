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
require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < Test::Unit::TestCase
  fixtures :all

  def test_to_strings
    check_strings Request, :resume, :description
  end

  def test_presence_of_attributes
    recipient = recipients(:recipient_00001)
    request = Request.new({:description => 'description', :resume => 'resume',
        :recipient => recipient, :submitter => recipient.user,
        :statut => statuts(:statut_00001), :severite => severites(:severite_00001),
        :contract => recipient.user.contracts.first })
    # must have a recipient
    assert request.save

    # comment table must have things now ...
    c = Comment.find :first, :conditions => { :request_id => request.id }
    assert_equal c.request_id, request.id
    assert_equal c.severite, request.severite
    assert_equal c.statut, request.statut
    assert_equal c.ingenieur, request.ingenieur
  end

  def test_scope
    Request.set_scope([Contract.find(:first).id])
    Request.find(:all)
    Request.remove_scope
  end

  def test_arrays
    check_arrays Request, :remanent_fields
  end

  def test_fragments
    assert !Request.find(:first).fragments.empty?
  end

  def test_finder
    request = requests(:request_00010)
    comment = request.find_status_comment_before(request.last_status_comment)
    assert_not_nil comment
  end

  def test_helpers_function
    Request.find(:all).each { |r|
      r.time_running?
      result = r.state_at(Time.now)
      assert_instance_of Request, result
      r.critical?
      assert_not_nil r.client
      assert_not_nil r.commitment
      assert_instance_of Fixnum, r.interval
      # they can be nil, but we need to check'em too
      r.elapsed_formatted
      r.full_software_name
    }
  end

  def test_reset_elapsed
    Request.find(:first).reset_elapsed
  end

  def test_set_defaults
    request = Request.find(:first)
    request.statut_id = nil
    request.set_defaults(nil, request.recipient, {})
    request.set_defaults(request.ingenieur, nil, {})
  end

=begin
  TODO : rework with rule contract model
  def test_client
    r = Request.find 1,2
    c = Client.find 1
    assert_equal r[0].client, c
    assert_equal r[1].client, c
  end

  def test_respect_workaround_and_correction
    r = Request.find 3
    c = Contract.find 2
    assert_kind_of String, r.respect_workaround(c.id)
    assert_kind_of String, r.respect_correction(c.id)
  end

  # No test for affiche_temps_ecoule and affiche_temps_correction
  # because the display of the time may change
  def test_temps_correction
    r = Request.find 3
    assert_operator r.temps_correction, '>=', 0
    assert_equal r.temps_workaround, 0
  end
  def test_delais_correction
    r = Request.find 3
    assert_equal r.delais_correction, 475200.0
  end
  def test_temps_rappel
    r = Request.find 3
    assert_equal r.temps_rappel, 0
    assert_equal r.affiche_temps_rappel, '-'
  end
  def test_commitment
    r = Request.find 3
    e = Commitment.find 1
    assert_equal r.commitment(3), e
  end
  def test_affiche_temps_ecoule
    r = Request.find 3
    assert r.affiche_temps_ecoule
  end
=end

end
