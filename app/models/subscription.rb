class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :model, :polymorphic => true

  validates_presence_of :user, :model
  validates_uniqueness_of :user_id, :scope => [ :model_type, :model_id ],
    :message => _('You can be suscribe only one time on this model.')

  def name
    _('Subscription for %s on %s #%s') % [ self.user.name, self.model.type, self.model.id ]
  end

  def self.destroy_all(conditions = nil)
    res = true
    find(:all, :conditions => conditions).each do |s|
      to_destroy = true
      if s.model.is_a? Contract or s.model.is_a? Issue
        subscriptions = find(:all, :conditions =>
          { :model_type => s.model_type, :model_id => s.model_id })
        #If there is only one subscriber to this model
        if subscriptions.size <= 1
          s.errors.add_to_base(_('You can not unsubscribe to this model,
            because your are the last one watching it.'))
          to_destroy = false
        end
      end
      s.destroy if to_destroy
      res &= to_destroy
    end
    res
  end
  
end
