#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
#
# This helpers is here to put links helper not really 
# related to any model or controller.
#
# They help to generate link with image, for instance, 
# or link to files.
#
# It contains also general links in the header/footer part 
# 
module LinksHelper

  # this contains the hash for escaping hover effect for images
  # this is put in every links with image
  NO_HOVER = { :class => 'no_hover' }

  # Call it like this : link_to_file(document, 'fichier', 'nomfichier')
  # don't forget to update his public alter ego just below
  # DO NOT EVER CALL this method with 'public' parameter set 
  # to true, use <b>public_link_to_file</b> instead
  #
  def link_to_file(record, file, options={}, public = false)
    if record and record.send(file) and File.exist?(record.send(file))
      nom = record.send(file)[/[._ \-a-zA-Z0-9]*$/]
      if options[:image]
        show = image_patch and html_options = {:class => 'no_hover'} 
      else
        show = nom and html_options = {}
      end
      url = url_for_file_column(record, file, :absolute => true)
      if public
        public_link_to show, url, html_options
      else
        link_to show, url, html_options
      end
    else
      options[:else] ||= '-'
    end
  end

  def public_link_to_file(record, file, options={})
    link_to_file(record, file, options, true)
  end

  ### Header ###
  # TODO : put all those methods into another module 
  # and merge it dynamically in this module
  def public_link_to_home
    public_link_to(_('Accueil'), {:controller => 'bienvenue', :action => ''})
  end

  @@requests = {:controller => 'demandes', :action => 'list'}
  def link_to_requests
    link_to(_('Demandes'), @@requests, :title => _('Consulter vos demandes'))
  end

  @@softwares = {:controller => 'logiciels', :action => 'list'}
  def public_link_to_softwares
    public_link_to(_('Logiciels'), @@softwares, 
                   :title => _('Consulter les logiciels'))
  end

  @@contributions = {:controller => 'contributions', :action => 'select' }
  def public_link_to_contributions
    public_link_to(_('Contributions'), @@contributions, 
                   :title => _('Accédez à la liste des contributions réalisées sur votre périmètre'))
  end

  @@administration = {:controller => 'bienvenue', :action => 'admin'}
  def link_to_admin
    link_to _('Administration'), @@administration,
            :title => _('Interface d&lsquo;administration')
  end

  # About page
  @@about = {:controller => 'bienvenue', :action => 'about'}
  def public_link_to_about()
    public_link_to '?', @@about, 
                  :title => _("A propos de #{Metadata::NOM_COURT_APPLICATION}")
  end


  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(id, title=_('Mon&nbsp;Compte'))
    return '' unless id
    options = {:action => 'modify', :controller => 'account', :id => id }
    link_to title, options
  end

end
