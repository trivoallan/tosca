module ImagesHelper
  
  @@view = nil
  def image_view
    desc = 'Voir'
    @@view ||= image_tag('icons/b_view.png', :size => '15x15', 
                         :border => 0, :alt => 'Consulter' )
  end


  # We cannot cache a parametered image
  def image_create(message)
    image_tag("create_icon.png", :size => "16x16", 
                           :border => 0, :alt => "Déposer #{message}" )
  end

  @@edit = nil
  def image_edit
    @@edit ||= image_tag('edit_icon.gif', :size => '15x15', 
                        :border => 0, :alt => 'Modifier' )
  end

  @@delete = nil
  def image_delete
    @delete ||= image_tag('delete_icon.gif', :size => '15x17', 
                          :border => 0, :alt => 'Supprimer')
  end

  @@back = nil
  def image_back
    @@back ||= image_tag("back_icon.png", :size => "23x23",
                         :border => 0, :alt => 'Retour', :align => 'baseline' )
  end

  @@first_page = nil
  def image_first_page
    @@first_page ||= image_tag("first_page.png", :size => "14x14", :border => 0, 
                             :alt => 'Première page')
  end

  @@previous_page = nil
  def image_previous_page
    @@previous_page ||= image_tag("previous_page.png", :size => "14x14", 
                                :border => 0, :alt => 'Page précédente')
  end

  @@next_page = nil
  def image_next_page
    @@next_page ||= image_tag("next_page.png", :size => "14x14", 
                                :border => 0, :alt => 'Page suivante')
  end

  @@last_page = nil
  def image_last_page
    @@last_page ||= image_tag("last_page.png", :size => "14x14", 
                                :border => 0, :alt => 'Dernière page')
  end


  @@public = nil
  def image_public
    @@public ||= image_tag('public_icon.png', :size => '17x16', 
                           :border => 0, :alt => 'Rendre public')
  end

  @@private = nil
  def image_private
    @@private ||= image_tag('private_icon.png', :size => '12x14', 
                            :border => 0, :alt => 'Rendre privé')
  end


  @@spinner = nil
  def image_spinner
    @@spinner ||= image_tag('spinner.gif', :align => 'absmiddle', 
                            :border=> 0, :id => 'spinner', 
                            :style=> 'display: none;')
  end  
  @@folder = nil
  def image_folder
    @@folder ||= image_tag('folder_icon.gif', :size => '16x16',
                           :border => 0, :alt => 'Fichier', 
                           :align => 'baseline')
  end

end
