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
    if (request.statut_id != self.statut_id)
      request.errors.add_to_base _('The status of this request has already been changed by.')
    end
  end
  # We destroy attachment if appropriate
  # belongs_to don't allow us to call :dependent :'(
  before_destroy :delete_pj
  def delete_pj
    # We MUST have at least the first comment
    return false if self.demande.first_comment_id == self.id
    if !self.prive and self.demande.last_comment_id == self.id
      last_comment = self.demande.find_last_comment_before(self.id)
      if !last_comment
        self.errors.add_to_base(_('This request seems to be unstable.'))
        return false
      end
      self.demande.update_attribute :last_comment_id, last_comment.id
    end
    self.piecejointe.destroy unless self.piecejointe.nil?
    true
  end

  # update request attributes, when creating a comment
  after_create :update_request
  def update_request
    fields = %w(statut_id ingenieur_id severite_id)
    request = self.demande

    # don't update all attributes if we are on the first comment
    if request.first_comment_id != self.id
      #On met à jour les champs demandeO
      fields.each do |attr|
        #On ne met à jour que si ça a changé
        request[attr] = self[attr] if self[attr] and request[attr] != self[attr]
      end
      unless request.elapsed
        data = { :demande => request, :until_now => self.elapsed }
        Elapsed.create(data)
      end

    end
    request.last_comment_id = self.id unless self.prive
    request.expected_on = Time.now + 15.days
    #To update the demande.updated_on
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
