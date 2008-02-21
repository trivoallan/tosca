#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :user
  belongs_to :piecejointe
  belongs_to :statut
  belongs_to :severite
  belongs_to :ingenieur

  validates_length_of :corps, :minimum => 5,
    :warn => _('You must have a comment with at least 5 characters')
  validates_presence_of :user

  validate do |record|
    if record.demande.nil?
      record.errors.add _('You must indicate a valid request')
    end
  end

  # On détruit l'éventuelle pièce jointe
  # le belongs_to ne permet pas d'appeler :dependent :'(

  # permet de récuperer l'état du commentaire en texte
  # le booléen correspondant est :  prive = true || false
  def etat
    ( prive ? _("private") : _("public") )
  end

  # Used for outgoing mails feature, to keep track of the request.
  def mail_id
    return "#{self.demande_id}_#{self.id}"
  end

  def name
    id.to_s
  end

  # This method search, create and add an attachment to the comment
  def add_attachment(params)
    attachment = params[:piecejointe]
    return false unless attachment and !attachment[:file].blank?
    attachment = Piecejointe.new(attachment)
    attachment.commentaire = self
    attachment.save and self.update_attribute(:piecejointe_id, attachment.id)
  end

  private
  before_create :check_status
  def check_status
    request = self.demande
    if (request.statut_id == self.statut_id)
      request.errors.add_to_base _('The status of this request has already been changed.')
    end
    if (self.statut_id && self.prive)
      request.errors.add_to_base _('You cannot privately change the status')
    end
  end

  # We destroy a few things, if appropriate
  # Attachments, Elapsed Time or Request coherence is checked
  before_destroy :delete_dependancies
  def delete_dependancies
    request = self.demande

    # We MUST have at least the first comment in a request
    return false if request.first_comment_id == self.id
    if !self.prive and request.last_comment_id == self.id
      other_comment = request.find_other_comment(self.id)
      if !other_comment
        self.errors.add_to_base(_('This request seems to be unstable.'))
        return false
      end
      request.update_attribute :last_comment_id, last_comment.id
    end

    request.elapsed.remove(self)
    self.piecejointe.destroy unless self.piecejointe.nil?
    true
  end

  # update request attributes, when creating a comment
  after_create :update_request
  def update_request
    fields = %w(statut_id ingenieur_id severite_id)
    request = self.demande

    # Update all attributes
    if request.first_comment_id != self.id
      fields.each do |attr|
        request[attr] = self[attr] if self[attr] and request[attr] != self[attr]
      end
    else
      fields.each { |attr| self[attr] = request[attr] }
    end

    # auto-assignment to current engineer
    if request.ingenieur_id.nil? && self.user.ingenieur
      request.ingenieur = self.user.ingenieur
    end

    # update cache of elapsed time
    rule = request.contrat.rule
    if request.elapsed.nil?
      options = { :demande => request, :until_now => rule.elapsed_on_create }
      request.elapsed = Elapsed.new(options)
    end
    unless self.statut_id.nil?
      last_status_comment = request.find_status_comment_before(self)
      self.elapsed = rule.compute_elapsed_between last_status_comment, self
    end
    request.elapsed.add(self)

    request.last_comment_id = self.id unless self.prive

    request.save
  end

  # reset the request to its previous status state
  after_destroy :reset_request
  def reset_request
    request = self.demande
    if self.id >= request.last_comment_id and not self.statut_id.nil?
      options = { :order => "commentaires.created_on DESC",
        :conditions => 'commentaires.statut_id IS NOT NULL' }
      last_status_comment = request.commentaires.find(:first, options)
      statut_id = (last_status_comment ? last_status_comment.statut_id : 1)
      return request.update_attribute(:statut_id, statut_id)
    end
    true
  end

end
