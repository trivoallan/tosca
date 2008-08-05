class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :user
  belongs_to :attachment
  belongs_to :statut
  belongs_to :severite
  belongs_to :ingenieur

  validates_length_of :corps, :minimum => 5,
    :warn => _('You must have a comment with at least 5 characters')
  validates_presence_of :user

  validate do |record|
    request = record.demande
    if record.demande.nil?
      record.errors.add_to_base _('You must indicate a valid request')
    end
    if (request && !request.new_record? && request.statut_id == record.statut_id)
      record.errors.add_to_base _('The status of this request has already been changed.')
    end
    if (record.statut_id && record.prive)
      record.errors.add_to_base _('You cannot privately change the status')
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
    attachment = params[:attachment]
    return false unless attachment and !attachment[:file].blank?
    attachment = Attachment.new(attachment)
    attachment.commentaire = self
    attachment.save and self.update_attribute(:attachment_id, attachment.id)
  end

  def fragments
    [ ]
  end

  private

  # We destroy a few things, if appropriate
  # Attachments, Elapsed Time or Request coherence is checked
  before_destroy :delete_dependancies
  def delete_dependancies
    request = self.demande

    # We MUST have at least the first comment in a request
    return false if request.first_comment_id == self.id

    # Updating last_comment pointer
    # TODO : Is this last_comment pointer really needed ?
    # Since we have the view cache, it does not seem pertinent, now
    if !self.prive and request.last_comment_id == self.id
      last_comment = request.find_other_comment(self.id)
      if !last_comment
        self.errors.add_to_base(_('This request seems to be unstable.'))
        return false
      end
      request.update_attribute :last_comment_id, last_comment.id
    end

    request.elapsed.remove(self) if request.elapsed
    self.attachment.destroy unless self.attachment.nil?
    true
  end

  after_destroy :update_status
  def update_status
    return true if self.statut_id.nil? || self.statut_id == 0

    request = self.demande
    options = { :order => 'created_on DESC', :conditions =>
      'commentaires.statut_id IS NOT NULL' }
    last_one = request.commentaires.find(:first, options)
    return true unless last_one
    request.update_attribute(:statut_id, last_one.statut_id)
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
    contract = request.contract
    rule = contract.rule
    if request.elapsed.nil?
      request.elapsed = Elapsed.new(request)
      self.update_attribute :elapsed, rule.elapsed_on_create
    elsif !self.statut_id.nil?
      last_status_comment = request.find_status_comment_before(self)
      elapsed = rule.compute_between(last_status_comment, self, contract)
      self.update_attribute :elapsed, elapsed
    end
    request.elapsed.add(self)

    request.last_comment_id = self.id unless self.prive

    request.save
  end



end
