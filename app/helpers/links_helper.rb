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
    return '-' unless record
    filepath = record.send(file)
    unless filepath.blank? or not File.exist?(filepath)
      filename = filepath[/[._ \-a-zA-Z0-9]*$/]
      if options[:image]
        show = image_patch and html_options = {:class => 'no_hover'}
      else
        show = filename and html_options = {}
      end
      url = url_for_file_column(record, file, :absolute => true)
      if public
        public_link_to show, url, html_options
      else
        link_to show, url, html_options
      end
    end
  end

  def public_link_to_file(record, file, options={})
    link_to_file(record, file, options, true)
  end

  ### Header ###
  # TODO : put all those methods into another module
  # and merge it dynamically in this module
  @@home = nil
  def public_link_to_home
    @@home ||= public_link_to(_('Accueil'), index_bienvenue_path)
  end

  @@requests = nil
  def link_to_requests
    @@requests ||= link_to(_('Demandes'), demandes_url, :title =>
                           _('Consulter vos demandes'))
  end

  @@softwares = nil
  def public_link_to_softwares
    @@softwares ||= public_link_to(_('Logiciels'), logiciels_url, :title =>
                                   _('Consulter les logiciels'))
  end

  @@contributions = nil
  def public_link_to_contributions
    @@contributions ||= public_link_to(_('Contributions'), contributions_url,
       :title => _('Accédez à la liste des contributions réalisées sur votre périmètre'))
  end

  @@administration = nil
  def link_to_admin
    @@administration ||= link_to(_('Administration'), {:action => "admin" , :controller => "bienvenue"},
                           :title => _('Interface d&lsquo;administration'))
  end

  # About page
  @@about = nil
  def public_link_to_about()
    @@about ||= public_link_to('?', {:action => "about" , :controller => "bienvenue"},
       :title => _("A propos de %s") % Metadata::NOM_COURT_APPLICATION)
  end


  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(account_id, title=_('Mon&nbsp;Compte'))
    return '' unless account_id
    link_to title, modify_account_url(:id => account_id)
  end

end
