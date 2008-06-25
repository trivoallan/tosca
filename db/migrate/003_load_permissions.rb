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

    roles = [ manager_id, expert_id, customer_id, viewer_id ]
    access = [ [ '/auto_complete', 'All kinds of Auto completion' ],
               [ '/ajax', 'All kinds of ajax view' ],
               [ '^account/(edit|update|show)$', 'Viewing and editing its own account' ],
               [ '^welcome/suggestions$', 'Allow comments on this software' ],
               [ '^export/', 'All kinds of export' ],
               [ '^files/download$', 'All kinds of download' ],
               [ '^piecejointes/uv$', 'Attachments preview' ],
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
               [ '^urlreversements/', 'Manage their own urls of contributions' ],
               [ '^tags/', 'Manage tags' ]
             ]
    add_permission.call(roles, access)

    roles = [ manager_id ]
    access = [ [ '^account/(signup|new|create)', 'Manage account' ],
               [ '^binaires/(?!destroy)', 'Manage binaries' ],
               [ '^clients/(?!destroy)', 'Manage clients' ],
               [ '^competences/(?!destroy)', 'Manage knowledge' ],
               [ '^contracts/(?!destroy)', 'Manage contracts' ],
               [ '^demandes/(?!destroy)', 'Manage requests' ],
               [ '^groupes/(?!destroy)', 'Manage groups of software' ],
               [ '^images/(?!destroy)', 'Manage logos of software & clients' ],
               [ '^ingenieurs/(?!(destroy|new))',
                 'List knowledges of human ressources' ],
               [ '^logiciels/(?!destroy)', 'Manage software' ],
               [ '^paquets/(?!destroy)', 'Manage packages' ],
               [ '^machines/(?!destroy)', 'Manage servers' ],
               [ '^teams/(?!destroy)', 'Manage teams' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id, customer_id, viewer_id ]
    access = [ [ '^binaires/(show|index)$', 'Read-only access to binaries' ],
               [ '^clients/show$', 'Read-only access to clients offers' ] ,
               [ '^demandes/(index|print|show)$', 'Read access to requests' ],
               [ '^logiciels/(index|show)$', 'Read-only access to software' ],
               [ '^paquets/(index|show)$', 'Read-only access to package' ],
               [ '^socles/show$', 'Read-only access to system' ],
               [ '^teams/(index|show)$', 'Read-only access to the teams' ],
               [ '^tags/(index|show|create|new)$', 'Read-only access to the tags' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id ]
    access = [ [ '^clients/index$', 'Read-only access to list clients offers' ],
               [ '^demandes/(link|unlink)_contribution$', 'Link contribution with request' ],
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
                  'Hability to comment a request' ],
                [ '^demandes/(new|create|pending)$',
                   'Write access to requests & Pending View' ] ]
    add_permission.call(roles, access)

    roles = [ public_id ]
    access = [ [ '^access/denied$', 'Page for denying access' ],
               [ '^account/(login|logout)$', 'Access to login system' ],
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
