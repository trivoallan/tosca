class NewsController < ApplicationController
  include REXML

  def index
    @new_pages, @news = paginate :new, :per_page => 15
  end

  def show
    @new = New.find(params[:id])
  end

  def new
    @new = New.new
    @new.ingenieur = @ingenieur
    _form
  end

  def create
    @new = New.new(params[:new])
    if @new.save
      flash[:notice] = 'New was successfully created.'
      redirect_to news_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @new = New.find(params[:id])
    _form
  end

  def update
    @new = New.find(params[:id])
    if @new.update_attributes(params[:new])
      flash[:notice] = 'New was successfully updated.'
      redirect_to new_path(@new)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    New.find(params[:id]).destroy
    redirect_to news_path
  end

  def newsletter; end
  def newsletter_result
    edito = New.find params['edito']
    long_article = New.find params['long_article']

    # TODO : verify the data from the user
    # TODO : add french strings into translation
    options = {
      :edito => [ edito.subject, edito.body],
      :articles => ['et un', 'et deux'],
      :long_article => [long_article.subject, long_article.ingenieur.name,
        long_article.body]
    }
    # The template : 
    #   the fields should be empty ( I add and not replace)
    #   We may modify in the content.xml the fields.
    #   a simple way is to use a text area and no rectangle.
    #   If you want to use rectangle, you must change the fonction html2document and
    # initialize_newsletter
    template_path = 'public/newsletter_template.odp'
    Tempfile.open 'tosca_newsletter_tmp.odp' do |temp_file|
      FileUtils.cp template_path, temp_file.path
      compute_newsletter temp_file.path, options
      # send_file may create temporary file in /tmp, be don't delete them.
      send_file temp_file.path, :filename => 'newsletter.odp'
    end
  end

  private
  def _form
    @ingenieurs = Ingenieur.find_select(User::SELECT_OPTIONS)
    @clients = Client.find_select
    @logiciels = Logiciel.find_select
  end
  # Modify the newsletter template given in argument
  # options = {
  #   :edito => ['title', 'body']
  #   :articles => ['content on the left', 'content on the right'],
  #   :long_article => ['title', 'author', 'body']
  # }
  # for an empty newsletter : options = {}
  # ***********************************
  # Pour ajouter les petits articles: 
  #
  # 1. Nommer les éléments à remplir ( on peut le faire dans openoffice)
  # ATTENTION : les fonctions ici sont faites pour remplir des zone de texte
  #  ( <draw:text-box> ). Pour remplir autre chose, il faut modifier toutes ces
  #  fonctions. 
  #
  # 2. Récupérér les éléments dans le initiaize_newsletter ci-dessus.
  #
  # 3. appliquer les styles avec html2opendocument. Attention aux styles ! Si on supprime des éléments dans le document,
  # certains style disparaissent ... 
  # Pour récupérer les styles, il faut éditer dézipper le odp, et aller chercher
  # le style dans le content.xml directement.
  # ***********************************
  def compute_newsletter file_path, options
    Zip::ZipFile.open(file_path) do |zip_file|

      doc = Document.new zip_file.read('content.xml')
      newsletter = initialize_newsletter doc
      if options
        if options[:edito]
          if options[:edito][0]
            html2opendocument newsletter.edito_title, options[:edito][0], :edito_title
          end
          if options[:edito][1]
            html2opendocument newsletter.edito_body, options[:edito][1], :edito_body
          end
        end
        if options[:long_article]
            if options[:long_article][0]
              html2opendocument newsletter.long_article_title, options[:long_article][0], :long_article_title
            end
            if options[:long_article][1]
              html2opendocument newsletter.long_article_author, options[:long_article][1], :long_article_author
            end
            if options[:long_article][2]
              html2opendocument newsletter.long_article_body, options[:long_article][2], :long_article_body
            end
        end
        if options[:articles]
          
        end
      end

      zip_file.get_output_stream('content.xml') { |f| f.puts doc }
    end
  end
  # initialize the elements to be changed in the newsletter
  def initialize_newsletter doc
    newsletter_struct = Struct.new(:edito_title, :edito_body,
                                   :articles_left, :articles_right,
                                   :long_article_title, :long_article_author, :long_article_body )
    presentation = 
      doc.elements['office:document-content/office:body/office:presentation']

    elts = newsletter_struct.new(
      presentation.elements["*/draw:frame[@draw:name='edito_title']/draw:text-box"],
      presentation.elements["*/draw:frame[@draw:name='edito_body']/draw:text-box"],

      presentation.elements["*/draw:custom-shape[@draw:name='articles_left']"],
      presentation.elements["*/draw:custome-shape[@draw:name='articles_right']"],

      presentation.elements["*/draw:frame[@draw:name='long_article_title']/draw:text-box"],
      presentation.elements["//draw:frame[@draw:name='long_article_author']/draw:text-box"],
      presentation.elements["*/draw:frame[@draw:name='long_article_body']/draw:text-box"] )
      return elts
  end
  # puts the html to the openddocument template
  # argument : 
  #   parent is the element in which we want to insert our text
  #   html is the text, in html because it comes from tiny_mce
  # Usage : 
  # html2opendocument newsletter.edito_title, options[:edito][0], :edito_title
  # TODO : Support for bold, italic, div, ... all except <p> :)
  def html2opendocument(parent, html, article)
    case article
      when :edito_title then style_p = 'P10' and style_span = 'T3'
      when :edito_body then style_p = 'P10' and style_span = 'T4'

      when :articles_left then style_p = 'P10' and style_span ='T4'
      when :articles_right then style_p = 'P10' and style_span ='T4'
      when :long_article_title then style_p = 'P13' and style_span = 'T11'
      when :long_article_author then style_p ='P14' and style_span = 'T10'
      when :long_article_body then style_p = 'P10' and style_span = 'T4'
      else style_p = 'P10' and style_span = 'T4'
    end
    # We must split html according to <p>...</p>
    i = 0
    html.split(/<\/?p>/).each do |bloc|
      if bloc != ''
        text_p = Element.new 'text:p'
        text_p.add_attribute 'text:style-name', style_p
        span = Element.new 'text:span'
        span.add_attribute 'text:style-name', style_span

        bloc.gsub!(/(&nbsp;)+/i, ' ')
        bloc.gsub!(/(&#39;)+/i, '\'')
        span.text = bloc
        text_p.add_element span
        parent[i] = text_p

        i += 1
      end
    end
=begin
    Taken from the mail html2text converter. Kept here if we need to alter
    other things into the html2odt converter. 
    TODO : a merge in a converter plugin ?

    text = html.
      gsub(/(&nbsp;)+/im, ' ').squeeze(' ').strip.gsub("\n",'').
      gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

    links = []
    linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>([^>]*)<[^>]*>/i
    while linkregex.match(text)
      links << $~[3]
      text.sub!(linkregex, "#{$~[4]}[#{links.size}]")
    end

    text = CGI.unescapeHTML(
      text.
        gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
        gsub(/<!--.*-->/m, '').
        gsub(/<hr(| *[^>]*)>/i, "----------------------------\n").
        gsub(/<li(| [^>]*)>/i, "\n * ").
        gsub(/<blockquote(| [^>]*)>/i, '> ').
        gsub(/<br(| *[^>]*)>/i, "\n").
        gsub(/<\/(h[\d]+|p)(| [^>]*)>/i, "\n\n").
        gsub(/<\/address(| [^>]*)>/i, "\n").
        gsub(/<\/pre(| [^>]*)>/i, "\n").
        gsub(/<\/(b|strong)[^>]*>/i, "</text:span>").
        gsub(/<\/?(i|em)[^>]*>/i, "/").
        gsub(/<\/?u[^>]*>/i, "_").
        gsub(/<[^>]*>/, '')
    )
    for i in (0...links.size).to_a
      text = text + "\n  [#{i+1}] <#{CGI.unescapeHTML(links[i])}>" unless links[i].nil?
    end

    text
=end
  end

end
