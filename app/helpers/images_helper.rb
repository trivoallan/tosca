#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ImagesHelper

  # TODO : utiliser image_options (cf image_delete pour exemple)
  # We cannot cache a parametered image

  # por éviter la réaffection de desc à chaque coup
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc }
    options.update(:size => size) if size
    options
  end

  # Database manipulation

  def image_create(message)
    desc = "Déposer #{message}"
    image_tag("create_icon.png", image_options(desc, '16x16'))
  end

  @@view = nil
  def image_view
    @@view ||= image_tag('icons/b_view.png', image_options('Consulter', '15x15'))
  end

  @@edit = nil
  def image_edit
    @@edit ||= image_tag('edit_icon.gif', image_options('Modifier', '15x15'))
  end

  @@delete = nil
  def image_delete
    @delete ||= image_tag('delete_icon.gif', image_options('Supprimer', '15x17'))
  end

  # Navigation

  @@back = nil
  def image_back
#     @@back ||= image_tag("back_icon.png", image_options('retour', '23x23'))
    @@back ||= image_tag("back3.gif", image_options('retour', '15x15'))
  end

  @@first_page = nil
  def image_first_page
    desc = 'Première page'
    @@first_page ||= image_tag("first_page.png", image_options(desc, '14x14')) 
  end

  @@previous_page = nil
  def image_previous_page
    desc = 'Page précédente'
    @@previous_page ||= image_tag("previous_page.png", image_options(desc, '14x14'))
  end


  @@next_page = nil
  def image_next_page
    desc = 'Page suivante'
    @@next_page ||= image_tag("next_page.png", image_options(desc, '14x14'))
  end

  @@last_page = nil
  def image_last_page
    desc = 'Dernière page'
    @@last_page ||= image_tag("last_page.png", image_options(desc, '14x14'))
  end

  @@folder = nil
  def image_folder
    desc = 'Fichier'
    @@folder ||= image_tag('folder_icon.gif', image_options(desc, '16x16'))
  end

  @@patch = nil
  def image_patch(desc = 'Contribution')
    @@patch ||= image_tag('patch.gif', image_options(desc, '16x16'))
  end

  # Security

  @@public = nil
  def image_public
    desc = 'Rendre public'
    @@public ||= image_tag('public_icon.png', image_options(desc, '17x16'))
  end

   # pas mis en cache, celle ci est paramétrée
  def image_private(desc = 'Rendre privé')
    image_tag('private_icon.png', image_options(desc, '12x14'))
  end

  # Logos

  @@logo_08000 = nil
  def logo_08000
    @@logo_08000 ||= image_tag('logo_08000.gif', image_options('08000 LINUX'))
  end

  @@logo_lstm = nil
  def logo_lstm
    @@logo_lstm ||= image_tag('logo_lstm.gif', image_options('Accueil'))
  end

  @@logo_ruby = nil
  def logo_ruby
    desc = 'OSSA on rails'
    @@logo_ruby ||= image_tag('ruby.png', image_options(desc, '15x15'))
  end

  @@logo_linagora = nil
  def logo_linagora
    desc = 'OSSA on rails'
    @@logo_linagora ||= image_tag('logo_linagora.gif', image_options(desc, '176x44'))
  end

  @@image_favicon = nil 
  def image_favicon
    @@image_favicon ||= image_path("favicon.ico")
  end

  # Other

  @@spinner = nil
  def image_spinner
    @@spinner ||= image_tag('spinner.gif', :id => 'spinner',
                            :style=> 'display: none;')
  end


  @@expand = nil
  def image_expand
    @@expand ||= image_tag('navigation_expand.gif', image_options('expand'))
  end

  @@hide = nil
  def image_hide
    @@hide ||= image_tag('navigation_hide.gif', image_options('hide'))
  end

  @@date_from = nil
  def image_date_from
    @@date_from ||= image_tag('cal.gif', :size => '16x16', :title => 
      'Sélecteur de date',  :alt => 'Choisissez une date', :id => 'date_from',
      :onmouseover => "this.style.border='1px solid red';",
      :onmouseout => "this.style.border='none';", :style => 'cursor: pointer;')
  end

  # used to generate js for calendar
  # first args : id of input field
  # second args : id of image calendar trigger
  # call it : <%= script_date('date_before', 'date_to') %>
  def script_date(*args)
    '<script type="text/javascript">
       Calendar.setup({
        firstDay       :    0,            // first day of the week
        inputField     :    "%s", // id of the input field
        button         :    "%s",  // trigger for the calendar (button ID)
        align          :    "Tl",         // alignment : Top left
        singleClick    :    true,
             ifFormat       : "%%Y-%%m-%%d"  // our date only format
         });
   </script>' % args
  end


  @@date_to = nil
  def image_date_to
    @@date_to ||= image_tag('cal.gif', :size => '16x16', :title => 
      'Sélecteur de date',  :alt => 'Choisissez une date', :id => 'date_to',
      :onmouseover => "this.style.border='1px solid red';",
      :onmouseout => "this.style.border='none';", :style => 'cursor: pointer;')
  end


end
