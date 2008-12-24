class Subscription < ActiveRecord::Base
  belongs_to :user
  # Subscription can be made on
  # * Contract : emails for all issues
  # * Issue : emails for a specific issue
  # * Software : emails for all issues about a specific software
  belongs_to :model, :polymorphic => true

  validates_presence_of :user, :model
  validates_uniqueness_of :user_id, :scope => [ :model_type, :model_id ],
    :message => _('You can be suscribe only one time on this model.')

  def name
    _('Subscription for %s on %s #%s') %
      [ self.user.name, self.model.type, self.model.id ]
  end

  def self.destroy_by_user_and_model(user, model)
    self.first(:conditions => { :user_id => user.id, :model_type =>
                 model.class.to_s, :model_id => model.id }).destroy
  end

  before_destroy :check_uniqueness
  # For Contract, it MUST have at least one user watching it.
  def check_uniqueness
    return true if self.model_type != 'Contract'
    similars = { :model_type => self.model_type, :model_id => self.model_id }
    if self.class.count(:conditions => similars) <= 1
      self.errors.add_to_base(_('You can not unsubscribe to this contract, because your are the last one watching it.'))
      false
    else
      true
    end
  end

end
