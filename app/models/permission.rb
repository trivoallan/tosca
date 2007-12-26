#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# See <a href="http://wiki.rubyonrails.com/rails/show/AccessControlListExample">http://wiki.rubyonrails.com/rails/show/AccessControlListExample</a>
# and <a href="http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList">http://wiki.rubyonrails.com/rails/show/LoginGeneratorAccessControlList</a>


class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
end
