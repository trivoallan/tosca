#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class DemandesController < ApplicationController
  auto_complete_for :demande, :resume

  helper :filters, :contributions, :logiciels, :export, :appels, :socles

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

#   uses_tiny_mce :options => { :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold
#                                                              italic underline strikethrough separator
#                                                              justifyleft justifycenter justifyright indent outdent separator
#                                                              bullist numlist forecolor backcolor separator link
#                                                              unlink image undo redo},
#                               :theme_advanced_buttons2 => [],
#                               :theme_advanced_buttons3 => []}
  def auto_complete_for_logiciel_nom
    options = '%' + params[:logiciel][:nom].downcase + '%'

    @logiciels = Logiciel.find(:all, :select => 'nom',
      :conditions => [ 'LOWER(nom) LIKE :recherche OR 
        LOWER(description) LIKE :recherche',{:recherche => options } ], 
      :order => 'nom ASC')
    @resume = Logiciel.find(:all, :include => 'demandes',
      :select => 'nom',
      :conditions => ['demandes.resume LIKE ?', options ] )

    @logiciels += [@resume].flatten
    render :partial => 'dem_auto_complete'
  end
  def index
    list
    render :action => 'list'
  end

  def list
    #cas spécial : consultation directe
    if params['numero'] 
      redirect_to :action => :comment, :id => params['numero']  and return
    end

    options = { :per_page => 10, :order => 'updated_on DESC', 
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST }
    conditions = []

    # Specification of a filter f :
    special_cond = nil
    case params[:active]
    when '1' : special_cond = Demande::EN_COURS
    when '-1' : special_cond = Demande::TERMINEES
    end
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['logiciel', 'nom', 'logiciels.nom', :like ],
       ['demande', 'resume', 'demandes.resume', :like ],
       ['filters', 'client_id', 'beneficiaires.client_id', :equal ],
       ['filters', 'ingenieur_id', 'ingenieurs.id', :equal ],
       ['filters', 'typedemande_id', 'demandes.typedemande_id', :equal ],
       ['filters', 'severite_id', 'demandes.severite_id', :equal ],
       ['filters', 'statut_id', 'demandes.statut_id', :equal ]
     ], special_cond)
    flash[:conditions] = options[:conditions] = conditions if conditions

    # DIRTY HACK : WARNING
    # ALERT !!!! recopied in export/demandes !!!!
    # We need this hack for avoiding 7 includes
    # TODO : find a better way
    escope = {}
    if @beneficiaire
      escope = Demande.get_scope_without_include([@beneficiaire.client_id])
    end
    if @ingenieur and not @ingenieur.expert_ossa
      escope = Demande.get_scope_without_include(@ingenieur.client_ids)
    end
    Demande.with_exclusive_scope(escope) do
      @demande_pages, @demandes = paginate :demandes, options
    end

    # panel on the left side
    if request.xhr? 
      render :partial => 'requests_list', :layout => false
    else
      _panel
      @partial_for_summary = 'requests_info'
    end
  end

  def new
    @demande = Demande.new unless @demande
    _form @beneficiaire

    # si on est ingénieur, elle est pour nous par défaut
    @demande.ingenieur = @ingenieur
    # sans objet par défaut 
    @demande.severite_id = 4
    # statut "prise en compte" si ingénieur, sinon : "enregistrée"
    @demande.statut_id = (@ingenieur ? 2 : 1)

    @demande.beneficiaire_id = @beneficiaire.id if @beneficiaire
  end

  def create
    @demande = Demande.new(params[:demande])
    if @demande.save
      flash[:notice] = 'La demande a bien été créée.'
      Notifier::deliver_demande_nouveau({:demande => @demande, 
                                          :nom => @session[:user].nom, 
                                          :controller => self}, flash)
      redirect_to :action => 'list'
    else
      _form @beneficiaire
      render :action => 'new' 
    end
  end 


  # Used when submitting new request, in order to select
  # packages which are subjects to SLA.
  def ajax_display_packages
    @demande = Demande.new(params[:demande])
    
    begin
      beneficiaire = Beneficiaire.find @demande.beneficiaire_id
      contrat = Contrat.find :first, :conditions => 
      ['contrats.client_id = ?', beneficiaire.client.id ]
      logiciel = Logiciel.find(@demande[:logiciel_id])
    rescue  ActiveRecord::RecordNotFound
      @paquets = []
      flash[:warn] = "object not found ???"
    else
      # active = 1 : we only take supported packages. 
      # MySQL doesn't support true/false so Rails use Tinyint...
      conditions = { :conditions => 
        [ 'paquets.logiciel_id=? AND paquets.active=1', logiciel.id ], 
        :order => 'paquets.nom DESC' }
      @paquets = beneficiaire.client.paquets.find(:all, conditions) 
    end
  end

  # TODO : refaire le formulaire associé. 
  # qui a besoin d'un petit check
  # et virer ce vieux code legacy tout laid
  def ajax_update_delai
    demande = params[:demande]
    return render_text('') unless request.xhr? and 
      demande and (demande[:logiciel_id] != "")
    output = ''

    beneficiaire = Beneficiaire.find demande[:beneficiaire_id]
    contrat = Contrat.find :first, :conditions => ['client_id=?', beneficiaire.client.id ]
    unless contrat and beneficiaire
      return render_text(' => pas de contrat, pas d&lsquo;ossa') 
    end
    logiciel = Logiciel.find(demande[:logiciel_id])
    # active = 1 : we only take supported packages. 
    # MySQL doesn't support true/false so Rails use Tinyint...
    conditions = { :conditions => 
      [ 'paquets.logiciel_id=? AND paquets.active=1', logiciel.id ], 
      :order => 'paquets.nom DESC' }
    paquets = beneficiaire.client.paquets.find(:all, conditions) 

    severite = Severite.find(demande[:severite_id]) 
    typedemande = Typedemande.find(demande[:typedemande_id])
    return render_text('') unless paquets and severite and typedemande
    selecteds = demande[:paquet_ids]

    case paquets.size
    when 0
      output << "<p>Nous ne disposons d'aucun paquet concernant " + 
        logiciel.nom  + "</p>" 
    else 
      output << "<p>Précisez ici les paquets impactés par la demande :</p>" 
      output << "<table>"
      output << "<tr><td> <b>Paquets</b> </td>"
      output << "<td> Contournement  </td><td> Correction  </td><tr>"
      
      paquets.each do |p|
        contrat = Contrat.find(p.contrat_id)
        engagement = contrat.engagements.find_by_typedemande_id_and_severite_id(typedemande.id, severite.id)
        output << "<tr><td>"
        #TODO : remplacer ce truc par un <%= check_box ... %>
        output << "<input type=\"checkbox\" id=\"#{p.id}\""
        output << " name=\"demande[paquet_ids][]\" value=\"#{p.id}\""
        output << ' checked="checked"' if selecteds and selecteds.include? p.id.to_s
        #output << ' disabled="disabled" ' unless p.active
        output << "> : "
        output << "#{p.nom}-#{p.version}-#{p.release}</td>"
        if engagement
          output << "<td><%= Lstm.time_in_french_words(#{engagement.contournement}.days, true)%> </td>"
          output << "<td><%= Lstm.time_in_french_words(#{engagement.correction}.days, true)%> </td>"
        end
        output << "</tr>"
      end
      output << "</table>"
    end
    
    render :inline => output
  end

  def edit
    @demande = Demande.find(params[:id])
    _form @beneficiaire
  end

  def comment
    @demande = Demande.find(params[:id]) unless @demande
    conditions = [ "logiciel_id = ?", @demande.logiciel_id ] 
    @count = Demande.count(:conditions => conditions)
    # TODO c'est pas dry, cf ajax_comments
    options = { :order => 'created_on DESC', :include => [:identifiant], 
      :limit => 1, :conditions => { :demande_id => @demande.id } }
    options[:conditions][:prive] = false if @beneficiaire
    @last_commentaire = Commentaire.find(:first, options)    
    flash.now[:warn] = Metadata::DEMANDE_NOSTATUS unless @demande.statut

    @statuts = @demande.statut.possible()
    options =  { :conditions => 
      ['contributions.logiciel_id = ?', @demande.logiciel_id ] }
    @contributions = Contribution.find(:all, options)
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    
    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include'
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    select = "DISTINCT identifiants.id "
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => select, :joins => joins)

    @partial_for_summary = 'infos_demande'
  end

  def ajax_description
    return render_text('') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_description', :layout => false
  end

  def ajax_comments
   return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id]
    set_comments(@demande_id)
    render :partial => "tab_comments", :layout => false
  end

  def ajax_history
    return render_text('') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_history', :layout => false
  end

  def ajax_appels
    return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id] 
    conditions = [ 'appels.demande_id = ? ', @demande_id ]
    options = { :conditions => conditions, :order => 'appels.debut', 
      :include => [:beneficiaire,:ingenieur,:contrat,:demande] }
    @appels = Appel.find(:all, options)
    render :partial => 'tab_appels', :layout => false
  end

  def ajax_piecejointes
    return render_text('') unless request.xhr? and params[:id]
    @demande_id = params[:id]
    set_piecejointes(@demande_id)
    render :partial => 'tab_piecejointes', :layout => false
  end

  def ajax_cns
    return render_text('') unless request.xhr? and params[:id]
    @demande = Demande.find(params[:id]) unless @demande
    render :partial => 'tab_cns', :layout => false
  end

  def update
    @demande = Demande.find(params[:id])
    @demande.paquets = Paquet.find(params[:paquet_ids]) if params[:paquet_ids]
    if @demande.update_attributes(params[:demande])
      flash[:notice] = 'La demande a bien été mise à jour.'
      redirect_to :action => 'comment', :id => @demande
    else
      _form @beneficiaire
      render :action => 'edit'
    end
  end

  def destroy
    Demande.find(params[:id]).destroy
  end

  # TODO : enlever cette méthode quand elle passera dans le commentaire.
  def changer_ingenieur
    return render_text('') unless params[:id] and params[:ingenieur_id]
    @demande = Demande.find(params[:id])
    @demande.ingenieur = Ingenieur.find(params[:ingenieur_id].to_i)
    @demande.save!
    if @demande.ingenieur
      flash[:notice] = "La demande a été assignée correctement" 
      options = {:demande => @demande, :controller => self}
      Notifier::deliver_demande_assigner(options, flash)
    else
      flash[:notice] = "La demande n'est plus assignée"
    end
    redirect_to_comment
  end

  def associer_contribution
    return render_text('') unless params[:id] and params[:contribution_id]
    @demande = Demande.find(params[:id])
    @demande.update_attributes!(:contribution_id => params[:contribution_id])
    flash[:notice] = "Une contribution a été liée"
    redirect_to :action => 'comment', :id => @demande.id
  end

  def pretty_print
    @demande ||= Demande.find(params[:id]) 
    set_piecejointes(@demande.id)
    set_comments(@demande.id)
  end


  private
  def _panel
    @clients = Client.find_select()
    @statuts = Statut.find_select()
    @typedemandes = Typedemande.find_select()
    @severites = Severite.find_select()
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
  end

  # todo à retravailler
  def _form(beneficiaire)
    @socles = Socle.find_select
    if beneficiaire
      client = beneficiaire.client
      if client.support_distribution
        @logiciels = Logiciel.find_select
      else
        @logiciels = client.logiciels
      end
      @typedemandes = client.typedemandes
      @clients = [ client ] 
    else
      @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
      @logiciels = Logiciel.find_select
      @typedemandes = Typedemande.find_select
      @clients = Client.find(:all)
    end
    @severites = Severite.find_select
  end

  def redirect_to_comment
    redirect_to :action => 'comment', :id => @demande
  end

  def set_piecejointes(demande_id)
    conditions = [ 'commentaires.demande_id = ? ', demande_id ]
    options = { :conditions => conditions, :order => 
      'commentaires.updated_on DESC', :include => [:commentaire] }
    @piecejointes = Piecejointe.find(:all, options)
  end

  def set_comments(demande_id)
    if @beneficiaire
      @commentaires = Commentaire.find(:all, :conditions => 
         [ 'commentaires.demande_id = ? AND commentaires.prive = ? ', 
           demande_id, false ],
         :order => 'created_on ASC', :include => [:identifiant])
    elsif @ingenieur
      @commentaires = Commentaire.find(:all, :conditions => 
         [ 'commentaires.demande_id = ?', demande_id ],
         :order => "created_on ASC", :include => [:identifiant])
    end
    # On va chercher les identifiants des ingénieurs assignés
    # C'est un héritage du passé
    # TODO : s'en débarrasser avec une migration et un :include
    joins = 'INNER JOIN ingenieurs ON ingenieurs.identifiant_id=identifiants.id'
    select = "DISTINCT identifiants.* "
    @identifiants_ingenieurs = 
      Identifiant.find(:all, :select => select, :joins => joins)
  end

end

#<%= observe_form "demande_form",
# {:url => {:action => :ajax_update_delai},
#  :update => :delai,
#  :frequency => 15 } %>
#<%= observe_field "demande_severite_id", {
#  :url => {:action => :ajax_update_delai}, 
#  :update => :delai,  
#  :with => "severite_id" } 
#%>
#<%= observe_field "demande_logiciel_id",
# {:url => {:action => :ajax_update_paquets},
#  :update => :demande_paquets,
#  :with => "logiciel_id"} %>


