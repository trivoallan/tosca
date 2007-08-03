#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# This helpers is here to put in cache most of images
# urls generation. The images do not moves after the
# web server is launched, so there are computed only the
# first time one needs it and saved in class variables.
#
# You need to restart server in order to reinitialize them
# but you don't need to recompute them each time you want
# to display a picture.
#
# All image_* follow this scheme :
#   @@view = nil
#   def image_view
#     @@view ||= image_tag('icons/b_view.png', image_options('Consulter', '15x15'))
#   end
#
module ImagesHelper
  # TODO : utiliser image_options (cf image_delete pour exemple)
  # We cannot cache a parametered image

  # por éviter la réaffection de desc à chaque coup
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  def image_create(message)
    desc = _("Create %s") % message
    image_tag("create_icon.png", image_options(desc, '16x16'))
  end

  def logo_client(client)
    return '' if client.nil? or client.image.nil?
    image_tag(url_for_file_column(client.image, 'image', 'thumb'),
              image_options(client.nom))
  end

  @@view = nil
  def image_view
    desc = _("View")
    @@view ||= image_tag('icons/b_view.png', image_options(desc, '15x15'))
  end

  @@edit = nil
  def image_edit
    desc = _("Update")
    @@edit ||= image_tag('edit_icon.gif', image_options(desc, '15x15'))
  end

  @@delete = nil
  def image_delete
    desc = _("Delete")
    @@delete ||= image_tag('delete_icon.gif', image_options(desc, '15x17'))
  end

  @@hide_notice = nil
  def image_hide_notice
    desc = _("Hide")
    @@hide_notice ||= image_tag('delete_icon.gif', image_options(desc, '15x17'))
  end

  @@help= nil
  def image_help
    desc = _("Help")
    @@help ||= image_tag('icons/b_help.png', image_options(desc, '15x15'))
  end

  # Navigation

  @@home = nil
  def image_home
    desc = _("Home page")
    @@home ||= image_tag("home.gif", image_options(desc, '17x18'))
  end

  @@back = nil
  def image_back
    desc = _("Back")
    @@back ||= image_tag("back3.gif", image_options(desc, '15x15'))
  end

  @@first_page = nil
  def image_first_page
    desc = _("First page")
    @@first_page ||= image_tag("first_page.png", image_options(desc, '14x14'))
  end

  @@previous_page = nil
  def image_previous_page
    desc = _("Previous page")
    @@previous_page ||= image_tag("previous_page.png", image_options(desc, '14x14'))
  end

  @@next_page = nil
  def image_next_page
    desc = _("Next page")
    @@next_page ||= image_tag("next_page.png", image_options(desc, '14x14'))
  end

  @@last_page = nil
  def image_last_page
    desc = _("Last page")
    @@last_page ||= image_tag("last_page.png", image_options(desc, '14x14'))
  end

  @@folder = nil
  def image_folder
    desc = _("File")
    @@folder ||= image_tag('folder_icon.gif', image_options(desc, '16x16'))
  end

  @@patch = nil
  def image_patch
    desc = _("Contribution")
    @@patch ||= image_tag('patch.gif', image_options(desc, '16x16'))
  end

  # Security
  @@public = nil
  def image_public
    desc = _("Make public")
    @@public ||= image_tag('public_icon.png', image_options(desc, '17x16'))
  end

  @@private = nil
  def image_private
    desc = _("Make private")
    @@private ||= image_tag('private_icon.png', image_options(desc, '12x14'))
  end

  # Logos
  @@logo_08000 = nil
  def logo_08000
    @@logo_08000 ||= image_tag('logo_08000.gif', image_options('08000 LINUX'))
  end

  @@logo_lstm = nil
  def logo_lstm
    desc = _("Home page")
    @@logo_lstm ||= image_tag('logo_lstm.gif', image_options(desc))
  end

  @@logo_ruby = nil
  def logo_ruby
    desc = _("OSSA on rails")
    @@logo_ruby ||= image_tag('ruby.png', image_options(desc, '15x15'))
  end

  @@logo_linagora = nil
  def logo_linagora
    desc = _("OSSA on rails")
    @@logo_linagora ||= image_tag('logo_linagora.gif', image_options(desc, '176x44'))
  end

  @@image_favicon_png = nil
  def image_favicon_png
    @@image_favicon_png ||= image_path("favicon.png")
  end

  @@image_favicon_ico = nil
  def image_favicon_ico
    @@image_favicon_ico ||= image_path("favicon.ico")
  end

  @@image_print = nil
  def image_print
    desc = _("Print")
    @@image_print ||= image_tag('imprimer.png', image_options(desc, '22x22'))
  end

  # type mime icons
  @@image_txt = nil
  def image_txt
    @@image_txt ||= image_tag('icons/mime-type/txt.png')
  end

  @@image_pdf = nil
  def image_pdf
    @@image_pdf ||= image_tag('icons/mime-type/pdf.png')
  end

  @@image_ods = nil
  def image_ods
    @@image_ods ||= image_tag('icons/mime-type/ods.png')
  end

  @@image_csv = nil
  def image_csv
    @@image_csv ||= image_tag('icons/mime-type/csv.png')
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


  @@date_opt = { :alt => _("Choose a date"), :size => '16x16',
    :title => _("Select a date"),
    :onmouseover => "this.className='calendar_over';", :class => 'calendar_out',
    :onmouseout => "this.className='calendar_out';", :style => 'cursor: pointer;'
  }

  @@date_from = nil
  def image_date_from
    @@date_from ||= image_tag('cal.gif', @@date_opt.dup.update(:id => 'date_from'))
  end

  # Severity

  # Display an icon matching severity
  # They are stored in an array in order to cover all of 'em
  @@images_severite = Array.new(Severite.count)
  def icon_severite(d)
    result = @@images_severite[d.severite_id]
    if result.nil?
      desc = (d.respond_to?(:severites_nom) ? d.severites_nom : d.severite.nom)
      file_name = "severite_#{d.severite_id}.gif"
      @@images_severite[d.severite_id] = image_tag(file_name, :title =>
                                                   desc, :alt => desc)
      result = @@images_severite[d.severite_id]
    end
    result
  end

  # used to generate js for calendar. It uses an array of 2 arguments. See
  # link:"http://www.dynarch.com/projects/calendar/"
  #
  # first args : id of input field
  #
  # second args : id of image calendar trigger
  #
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
    @@date_to ||= image_tag('cal.gif', @@date_opt.dup.update(:id => 'date_to'))
  end

end
