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
class Elapsed < ActiveRecord::Base
  belongs_to :issue

  # Ctor, which ask for the depending issue and rule
  # Call it like this : Elapsed.new(@issue)
  def initialize(issue)
    super(:issue => issue, :until_now => 0)
  end

  # self-update with a comment
    # Please ensure that add() and remove() are consistent
  def add(comment)
    self.until_now += comment.elapsed

    if !self.taken_into_account? && comment.statut_id == 2
      self.taken_into_account = self.until_now
    end
    # Some shortcuts can be taken within the status model. for memo :
    # 5 Bypassed        6 Fixed
    # 7 Closed          8 Cancelled
    if !self.workaround? && [ 5, 6, 7, 8 ].include?(comment.statut_id)
      self.workaround = self.until_now
    end
    if !self.correction? && [ 6, 7, 8 ].include?(comment.statut_id)
      self.correction = self.until_now
    end

    save
  end

  # called when the comment is destroyed.
  # Please ensure that add() and remove() are consistent
  # TODO : fix this buggy method : what if there
  # is 2 comments for the same status ?
  def remove(comment)
    self.until_now -= comment.elapsed

    if self.taken_into_account? && comment.statut_id == 2
      self.taken_into_account = nil
    end
    if self.workaround? && comment.statut_id == 5
      self.workaround = nil
    end
    if self.correction? && comment.statut_id == 6
      self.correction = nil
    end

    save
  end

  # Overloaded in order to be consistent :
  # When there is a value of 0, it's been taken into account
  def taken_into_account?
    !read_attribute(:taken_into_account).nil?
  end

  def taken_into_account
    compute_value :taken_into_account, Statut::Active
  end

  def workaround
    compute_value :workaround, Statut::Bypassed
  end

  def correction
    compute_value :correction, Statut::Fixed
  end

  def taken_into_account_progress
    # 1 hour = 1/24 of a day
    progress(self.taken_into_account(), (1/24.0))
  end

  def workaround_progress
    issue = self.issue
    commitment = issue.commitment
    return 0.0 unless commitment
    progress(self.workaround(), commitment.workaround)
  end

  def correction_progress
    issue = self.issue
    commitment = issue.commitment
    return 0.0 unless commitment
    progress(self.correction(), commitment.correction)
  end

  # TODO
  def to_s
    '-'
  end

  # Convert a time relative to a commitment into an absolute time
  def self.relative2absolute(elapsed, interval)
    (elapsed / interval.hours).days
  end

  # Compute progress from an 'elapsed' time in "interval" reference,
  # with 'commitment' day
  def progress(elapsed, commitment)
    return -1 if commitment == -1
    elapsed / commitment.days
  end

  private
  def compute_value(value, statut_id)
    value = read_attribute(value)
    return value unless value.nil?

    issue = self.issue
    result = self.until_now
    return result unless issue.time_running?
    current = Comment.new(:created_on => Time.now, :statut_id => issue.statut_id)
    last = issue.last_status_comment
    contract = issue.contract
    result += contract.rule.compute_between(last, current, contract)
    result
  end


end
