#
# Copyright (c) 2006-2009 Linagora
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
module DigestReporting

  #contract is a Contract, issues is an array of DigestIssues
  DigestContracts = Struct.new(:contract, :issues)
  #issue is a Issue, issue_at is a Issue, comments is an array of Comment
  DigestIssues = Struct.new(:issue, :issue_at, :comments)

  def digest_result(period)
    @period = period
    @period = "year" if period.blank?
    updated = Time.now.send("beginning_of_#{@period}")
    # We must localise it after getting the (english) helper for the start date
    @period = _(@period)

    issues = @session_user.issues

    @result = []
    last_contract_id = nil
    issues.each do |r|
      if last_contract_id != r.contract_id
        dc = DigestContracts.new
        dc.contract = r.contract
        dc.issues = []
        @result.push(dc)
      end

      options = { :conditions => [ "created_on >= ? ", updated ] }

      dr = DigestIssues.new
      dr.issue = r
      dr.issue_at = r.state_at(updated)
      dr.comments = r.comments.all(options)
      @result.last.issues.push(dr)

      last_contract_id = r.contract_id
    end
  end

end
