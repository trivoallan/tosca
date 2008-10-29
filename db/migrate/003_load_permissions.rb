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
class LoadPermissions < ActiveRecord::Migration
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :permissions
  end
  class Permission < ActiveRecord::Base
    has_and_belongs_to_many :roles
  end

  def self.up
    # accounts id
    admin_id = Role.find(1)
    manager_id = Role.find(2)
    expert_id = Role.find(3)
    customer_id = Role.find(4)
    viewer_id = Role.find(5)
    public_id = Role.find(6)

    # Permission distribution
    add_permission = Proc.new do |roles, access|
      access.each { |a|
        p = Permission.create(:name => a.first, :info => a.last)
        p.roles = roles
        p.save
      }
    end

    Permission.destroy_all

    roles = [ admin_id ]
    access = [ [ '.*/.*', 'Full access' ] ]
    add_permission.call(roles, access)

    # TODO : this one contains rights to an extension.
    # There should be a mecanism to load new rights of an extension.
    roles = [ manager_id, expert_id, customer_id, viewer_id ]
    access = [ [ '/auto_complete', 'All kinds of Auto completion' ],
               [ '/ajax', 'All kinds of ajax view' ],
               [ '^account/(edit|update|show)$', 'Viewing and editing its own account' ],
               [ '^welcome/suggestions$', 'Allow comments on this software' ],
               [ '^export/', 'All kinds of export' ],
               [ '^files/download$', 'All kinds of download' ],
               [ '^attachments/uv$', 'Attachments preview' ],
               [ '^reporting/(configuration|general)$', 'Activity Report' ]
             ]
    add_permission.call(roles, access)

    roles = [ manager_id, expert_id ]
    access = [ [ '^account/become$',
                 'Helper for customer account' ],
               [ '^phonecalls/(?!destroy)', 'Manage calls' ],
               [ '^welcome/admin$', 'Administration page' ],
               [ '^commentaires/(?!destroy)', 'Manage comments' ],
               [ '^contributions/(?!destroy)', 'Manage contributions' ],
               [ '^documents/(?!destroy)', 'Manage documents' ],
               [ '^reporting/', 'Access to all kinds of reporting' ],
               [ '^socles/(?!destroy)', "Manage systems" ],
               [ '^urllogiciels/(?!destroy)', 'Manage urls of software' ],
               [ '^urlreversements/', 'Manage their own urls of contributions' ]
             ]
    add_permission.call(roles, access)

    roles = [ manager_id ]
    access = [ [ '^account/(signup|new|create)', 'Manage account' ],
               [ '^binaires/(?!destroy)', 'Manage binaries' ],
               [ '^clients/(?!destroy)', 'Manage clients' ],
               [ '^competences/(?!destroy)', 'Manage knowledge' ],
               [ '^contracts/(?!destroy)', 'Manage contracts' ],
               [ '^issues/(?!destroy)', 'Manage issues' ],
               [ '^commitments/(?!destroy)', 'Manage Service Level Agreement' ],
               [ '^groupes/(?!destroy)', 'Manage groups of software' ],
               [ '^images/(?!destroy)', 'Manage logos of software & clients' ],
               [ '^ingenieurs/(?!(destroy|new))', 'Manage human ressources' ],
               [ '^logiciels/(?!destroy)', 'Manage software' ],
               [ '^machines/(?!destroy)', 'Manage servers' ],
               [ '^releases/(?!destroy)', 'Manage releases' ],
               [ '^teams/(?!destroy)', 'Manage teams' ],
               [ '^releases/(?!destroy)', 'Manage release' ],
               [ '^tags/', 'Manage tags' ],
               [ '^versions/(?!destroy)', 'Manage version' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id, customer_id, viewer_id ]
    access = [ [ '^binaires/(show|index)$', 'Read-only access to binaries' ],
               [ '^clients/show$', 'Read-only access to clients offers' ] ,
               [ '^issues/(index|print|show)$', 'Read access to issues' ],
               [ '^logiciels/(index|show)$', 'Read-only access to software' ],
               [ '^paquets/(index|show)$', 'Read-only access to package' ],
               [ '^socles/show$', 'Read-only access to system' ],
               [ '^teams/(index|show)$', 'Read-only access to teams' ],
               [ '^releases/(index|show)$', 'Read-only access to versions' ],
               [ '^tags/(index|show|create|new)$', 'Read-only access to the tags' ],
               [ '^versions/(index|show)$', 'Read-only access to versions' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id ]
    access = [ [ '^clients/index$', 'Read-only access to list clients offers' ],
               [ '^issues/(link|unlink)_contribution$', 'Link contribution with issue' ],
               [ '^contracts/(index|show)$', 'Read-only access to contracts'] ]
    add_permission.call(roles, access)

    roles = [ customer_id, viewer_id ]
    access = [ [ '^documents/(select|list|index)$',
                 'Read-only access to documents' ]
             ]
    add_permission.call(roles, access)

    roles = [ manager_id, expert_id, customer_id, viewer_id ]
    access = [ [ '^account/index$', 'List accounts' ] ]
    add_permission.call(roles, access)

    roles = [ manager_id, expert_id, customer_id ]
    access = [ [ '^commentaires/(comment|show|edit|update)$',
                  'Hability to comment an issue' ],
                [ '^issues/(new|create|pending)$',
                   'Write access to issues & Pending View' ] ]
    add_permission.call(roles, access)

    roles = [ public_id ]
    access = [ [ '^access/denied$', 'Page for denying access' ],
               [ '^account/(login|logout|forgotten_password)$', 'Access to login system' ],
               [ '^welcome/(index|about|plan)$', 'Access to home pages' ],
               [ '^contributions/(index|select|show|list|feed)',
                 'Public read access to contributions' ],
               [ '^groupes/(index|show)', 'Public read access to groups' ],
               [ '^logiciels/(index|show)',
                 'Public read access to software' ],
               [ '^statuts/(index|help)$', 'Explanation of status' ] ]
    add_permission.call(roles, access)

  end

  def self.down
    Permission.destroy_all
  end
end
