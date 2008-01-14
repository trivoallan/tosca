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

    roles = [ admin_id ]
    access = [ [ '.*/.*', 'Full access' ] ]
    add_permission.call(roles, access)

    roles = [ manager_id, expert_id, customer_id, viewer_id ]
    access = [ [ '/auto_complete', 'All kinds of Auto completion' ],
               [ '/ajax', 'All kinds of ajax view' ],
               [ '^account/(edit|update|show)$', 'Viewing and editing its own account' ],
               [ '^bienvenue/suggestions$', 'Allow comments on this software' ],
               [ '^export/', 'All kinds of export' ],
               [ '^files/download$', 'All kinds of download' ],
               [ '^reporting/(configuration|general)$', 'Activity Report' ]
             ]
    add_permission.call(roles, access)

    roles = [ manager_id, expert_id ]
    access = [ [ '^appels/(?!destroy)', 'Manage calls' ],
               [ '^bienvenue/admin$', 'Administration page' ],
               [ '^commentaires/(?!destroy)', 'Manage comments' ],
               [ '^contributions/(?!destroy)', 'Manage contributions' ],
               [ '^documents/(?!destroy)', 'Manage documents' ],
               [ '^reporting/', 'Access to all kinds of reporting' ],
               [ '^socles/(?!destroy)', "Manage systems" ],
               [ '^urllogiciels/(?!destroy)', 'Manage urls of softwares' ],
               [ '^urlreversements/',
                 'Manage thier own urls of contributions' ],
             ]
    add_permission.call(roles, access)

    roles = [ manager_id ]
    access = [ [ '^account/(index|signup|new|create|become)', 'Manage account' ],
               [ '^binaires/(?!destroy)', 'Manage binaries' ],
               [ '^clients/(?!destroy)', 'Manage clients' ],
               [ '^competences/(?!destroy)', 'Manage knowledge' ],
               [ '^contrats/(?!destroy)', 'Manage contracts' ],
               [ '^demandes/(?!destroy)', 'Manage requests' ],
               [ '^groupes/(?!destroy)', 'Manage groups of softwares' ],
               [ '^ingenieurs/(?!(destroy|new))',
                 'List knowledges of human ressources' ],
               [ '^logiciels/(?!destroy)', 'Manage softwares' ],
               [ '^paquets/(?!destroy)', 'Manage packages' ],
               [ '^machines/(?!destroy)', 'Manage servers' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id, customer_id, viewer_id ]
    access = [ [ '^binaires/(show|index)$', 'Read-only access to binaries' ],
               [ '^clients/show$', 'Read-only access to clients offers' ] ,
               [ '^demandes/(new|create|index|print|show|comment|en_attente)$',                 'Read access to requests' ],
               [ '^logiciels/(index|show)$', 'Read-only access to software' ],
               [ '^paquets/(index|show)$', 'Read-only access to package' ],
               [ '^socles/show$', 'Read-only access to system' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id ]
    access = [ [ '^clients/index$',
                 'Read-only access to list clients offers' ] ]
    add_permission.call(roles, access)

    roles = [ customer_id, viewer_id ]
    access = [ [ '^documents/(select|list|index)$',
                 'Read-only access to documents' ]
             ]
    add_permission.call(roles, access)

    roles = [ expert_id, customer_id, viewer_id ]
    access = [ [ '^account/index$', 'List accounts' ] ]
    add_permission.call(roles, access)

    roles = [ expert_id, customer_id ]
    access = [ [ '^commentaires/(comment|edit|update)$',
                 'Hability to comment a request' ] ]
    add_permission.call(roles, access)

    roles = [ public_id ]
    access = [ [ '^acces/refuse$', 'Page for denying access' ],
               [ '^account/(login|logout)$', 'Access to login system' ],
               [ '^bienvenue/(index|about|plan)$', 'Access to home pages' ],
               [ '^contributions/(index|select|show|list)',
                 'Public read access to contributions' ],
               [ '^groupes/(index|show)', 'Public read access to groups' ],
               [ '^logiciels/(index|show)',
                 'Public read access to softwares' ],
               [ '^statuts/(index|help)$', 'Explanation of status' ] ]
    add_permission.call(roles, access)

  end

  def self.down
    Permission.find(:all).each{|p| p.destroy }
  end
end
