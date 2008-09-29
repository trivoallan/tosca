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
class Comment < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  belongs_to :attachment
  belongs_to :statut
  belongs_to :severite
  belongs_to :ingenieur

  validates_length_of :text, :minimum => 5,
    :warn => _('You must have a comment with at least 5 characters')
  validates_presence_of :user

  validate do |record|
    issue = record.issue
    if record.issue.nil?
      record.errors.add_to_base _('You must indicate a valid issue')
    end
    if (issue && issue.new_record? != true &&
        issue.first_comment_id != record.id &&
        issue.statut_id == record.statut_id &&
        record.new_record?)
      record.errors.add_to_base _('The status of this issue has already been changed.')
    end
    if (record.statut_id && record.private)
      record.errors.add_to_base _('You cannot privately change the status')
    end
  end
  
  before_validation do |record|
    if record.statut and not Statut::NEED_COMMENT.include? record.statut_id and html2text(record.text).strip.empty?
      record.text = _("The issue is now %s.") % record.statut.name
    end
  end

  # State in words of the comment (private or public)
  def etat
    ( private ? _("private") : _("public") )
  end

  # Used for outgoing mails feature, to keep track of the issue.
  def mail_id
    return "#{self.issue_id}_#{self.id}"
  end

  def name
    id.to_s
  end

  # This method search, create and add an attachment to the comment
  def add_attachment(params)
    attachment = params[:attachment]
    return false unless attachment and !attachment[:file].blank?
    attachment = Attachment.new(attachment)
    attachment.comment = self
    attachment.save and self.update_attribute(:attachment_id, attachment.id)
  end

  def fragments
    [ ]
  end

  private

  # We destroy a few things, if appropriate
  # Attachments, Elapsed Time or Issue coherence is checked
  before_destroy :delete_dependancies
  def delete_dependancies
    issue = self.issue

    # We MUST have at least the first comment in an issue
    return false if issue.first_comment_id == self.id

    # Updating last_comment pointer
    # TODO : Is this last_comment pointer really needed ?
    # Since we have the view cache, it does not seem pertinent, now
    if !self.private and issue.last_comment_id == self.id
      last_comment = issue.find_other_comment(self.id)
      if !last_comment
        self.errors.add_to_base(_('This issue seems to be unstable.'))
        return false
      end
      issue.update_attribute :last_comment_id, last_comment.id
    end

    issue.elapsed.remove(self) if issue.elapsed
    self.attachment.destroy unless self.attachment.nil?
    true
  end

  after_destroy :update_status
  def update_status
    return true if self.statut_id.nil? || self.statut_id == 0

    issue = self.issue
    options = { :order => 'created_on DESC', :conditions =>
      'comments.statut_id IS NOT NULL' }
    last_one = issue.comments.find(:first, options)
    return true unless last_one
    issue.update_attribute(:statut_id, last_one.statut_id)
  end

  # update issue attributes, when creating a comment
  after_create :update_issue
  def update_issue
    fields = %w(statut_id ingenieur_id severite_id)
    issue = self.issue

    # Update all attributes
    if issue.first_comment_id != self.id
      fields.each do |attr|
        issue[attr] = self[attr] if self[attr] and issue[attr] != self[attr]
      end
    else
      fields.each { |attr| self[attr] = issue[attr] }
    end

    # auto-assignment to current engineer
    if issue.ingenieur_id.nil? && self.user.ingenieur
      issue.ingenieur = self.user.ingenieur
    end

    # update cache of elapsed time
    contract = issue.contract
    rule = contract.rule
    if issue.elapsed.nil?
      issue.elapsed = Elapsed.new(issue)
      self.update_attribute :elapsed, rule.elapsed_on_create
    elsif !self.statut_id.nil?
      last_status_comment = issue.find_status_comment_before(self)
      elapsed = rule.compute_between(last_status_comment, self, contract)
      self.update_attribute :elapsed, elapsed
    end
    issue.elapsed.add(self)

    issue.last_comment_id = self.id unless self.private

    issue.save
  end

end
