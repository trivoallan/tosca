#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# UPLOAD > file_column.rb:l.596
#  :root_path => File.join(RAILS_ROOT, "files"),

# ROUTES > routes.rb
#  routing files to prevent download from public access

# MOVE FILES TO PROTECT > script shell
#  mv public/folders_to_protect files/

# DOCUMENTATION
#  http://wiki.rubyonrails.com/rails/pages/HowtoSendFiles
#  http://robertrevans.com/article/files-outside-public-directory
#  http://svn.techno-weenie.net/projects/plugins/acts_as_attachment/

class FilesController < ApplicationController

  def download
    file_type = params[:file_type]
 
    # mapping path
    map = {:piecejointe => 'file', 
           :contribution => 'patch',
           :document => 'fichier',
           :binaire => 'archive', 
           :photo => 'image' }

    # TODO : get model name without hash
    model = { :piecejointe => Piecejointe, 
              :contribution => Contribution,
              :document => Document,
              :binaire => Binaire, 
              :photo => nil }
    
    # building path
    root_path = "#{RAILS_ROOT}/files"
    root = [ root_path, file_type, map[file_type.intern] ] * '/'
    fullpath = [ root, params[:id], params[:filename] ] * '/'

    # special scope if piecejointe 
    if session[:beneficiaire] and file_type == 'piecejointe'
      client_id = session[:beneficiaire].client_id
      Piecejointe.set_scope(client_id) 
    end
    # rescue unless item not found
    target = model[file_type.intern].find(params[:id])
    send_file fullpath 

  rescue 
    # if error on findingtarget
    flash.now[:warn] = 'Ce fichier n\'existe pas.'
    redirect_to_home 
  end

end
