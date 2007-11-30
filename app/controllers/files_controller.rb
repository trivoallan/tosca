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

  # TODO : review and shorten this method. Camelize should to the job.
  def download
    file_type = params[:file_type]
 
    # mapping path
    map = {:piecejointe => 'file', 
           :contribution => 'patch',
           :document => 'fichier',
           :binaire => 'archive' }

    # TODO : get model name without hash
    model = { :piecejointe => Piecejointe, 
              :contribution => Contribution,
              :document => Document,
              :binaire => Binaire }
    
    # building path
    root = [ Metadata::PATH_TO_FILES, file_type, map[file_type.intern] ] * '/'
    # TODO : FIXME
    # the gsub on ' ' is needded, because url with '+' is weirdly reinterpreted.
    fullpath = [ root, params[:id], params[:filename].gsub(' ','+') ] * '/'
    

    # Attachment has to be restricted. 
    scope_active = (@beneficiaire and file_type == 'piecejointe')
    
    # Ensure that we can remove scope
    begin
      Piecejointe.set_scope(@beneficiaire.client_id) if scope_active
      target = model[file_type.intern].find(params[:id])
    ensure
      Piecejointe.remove_scope() if scope_active
    end

    send_file fullpath 

  rescue 
    # if error on finding target
    flash.now[:warn] = _("This file does not exist.")
    redirect_to_home 
  end

end
