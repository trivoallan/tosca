#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Ingenieur < ActiveRecord::Base
  acts_as_reportable
  belongs_to :user, :dependent => :destroy
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :contrats
  has_many :demandes
  has_many :appels


  INCLUDE = [:user]

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|_count|chef_de_projet|expert_ossa)$/ || c.name == inheritance_column }
  end
  
  def self.find_select_by_contrat_id(contrat_id)
    conditions = [ 'ci.contrat_id = ?', contrat_id ]
    joins = 'INNER JOIN contrats_ingenieurs ci ON ci.ingenieur_id=ingenieurs.id'
    options = {:find => {:conditions => conditions, :joins => joins}}
    Ingenieur.with_scope(options) do
      Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  def self.find_ossa(*args)
    conditions = 'ingenieurs.expert_ossa = 1'
    Ingenieur.with_scope({:find => {:conditions => conditions }}) {
      Ingenieur.find(*args)
    }
  end

  def self.find_presta(*args)
    conditions = ['ingenieurs.expert_ossa = ?', 0 ]
    Ingenieur.with_scope({:find => {:conditions => conditions }}) {
      Ingenieur.find(*args)
    }
  end

  # mis en cache, car utilisé dans les scopes
  def contrat_ids
    @contrat_ids ||= self.contrats.find(:all, :select => 'id').collect {|c| c.id}
  end

  # mis en cache, car utilisé dans les scopes
  def client_ids
    @client_ids ||= self.contrats.find(:all, :group => 'client_id',
         :select => 'client_id').collect {|c| c.client_id}
  end

  # Don't forget to make an :include => [:user] if you 
  # use this small wrapper.
  def nom
    user.name
  end

  alias_method :to_s, :nom
end
