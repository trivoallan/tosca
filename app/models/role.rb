#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# See <a href="http://wiki.rubyonrails.com/rails/show/AccessControlListExample">http://wiki.rubyonrails.com/rails/show/AccessControlListExample</a>
# and <a href="http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList">http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList</a>


class Role < ActiveRecord::Base
  acts_as_reportable
  has_and_belongs_to_many :permissions
  has_many :users

  def to_s
    name
  end
end
