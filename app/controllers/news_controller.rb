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
    edito, long_article = New.find params['edito'], params['long_article']

    options = {
      :edito => ['le titre', 'le corps</b> de ledito<br />retour à la ligne'],
      :long_article => ['le titre', 'lautheur', 'corps <b>du</b> message<br /> retour à al ligne']
    }
    template_path = 'public/newsletter_template.odp'
    Tempfile.open 'toto.odp' do |temp_file|
      FileUtils.cp template_path, temp_file.path
      compute_newsletter temp_file.path, options
      send_file temp_file.path, :filename => 'newsletter.odp'
    end
  end

  private
  def _form
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @clients = Client.find_select
    @logiciels = Logiciel.find_select
  end
  # initialize the elements to be changed in the newsletter
  def initialize_newsletter doc
    newsletter_struct = Struct.new(:edito_title, :edito_body,
                                   :long_article_title, :long_article_author, :long_article_body )
    presentation = 
      doc.elements['office:document-content/office:body/office:presentation']

    elts = newsletter_struct.new(
      presentation.elements["*/draw:frame[@draw:name='edito_title']/draw:text-box"],
      presentation.elements["*/draw:frame[@draw:name='edito_body']/draw:text-box"],

      presentation.elements["*/draw:frame[@draw:name='long_article_title']/draw:text-box"],
      presentation.elements["*/draw:frame[@draw:name='long_article_author']/draw:text-box"],
      presentation.elements["*/draw:frame[@draw:name='long_article_body']/draw:text-box"] )
      return elts
  end
  # Modify the newsletter template given in argument
  # options = {
  #   :edito => ['title', 'body']
  #   :long_article => ['title', 'author', 'body']
  # }
  # for an empty newsletter : options = {}
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
=begin
#         newsletter.author_long_article.text =
#           options[:long_article][1] ? options[:long_article][1] : ''
          newsletter.body_long_article.text =
            options[:long_article][2] ? options[:long_article][2] : ''
=end
        end
      end

      zip_file.get_output_stream('content.xml') { |f| f.puts doc }
    end
  end
  # puts the html to the openddocument template
  # argument : 
  #   parent is the element in which we want to insert our text
  #   html is the text, in html because it comes from tiny_mce
  # Usage : 
  # html2opendocument newsletter.edito_title, options[:edito][0], :edito_title
  # TODO : Support for bold, italic, div, ... all except <br /> :)
  def html2opendocument(parent, html, article)
    case article
      when :edito_title then style_p = 'P10' and style_span = 'T3'
      when :edito_body then style_p = 'P10' and style_span = 'T5'

      when :long_article_title then style_p = 'P13' and style_span = 'T11'
      when :long_article_author then style_p ='P14' and style_span = 'T10'
      when :long_article_body then style_p = 'P14' and style_span = 'T9'
      else style_p = 'P10' and style_span = 'T5'
    end
    # We must split de html according to <br /> (several bloc in opendoc)
    i = 0
    html.split('<br />').each do |bloc|
      if i != 0
        enter_p = Element.new 'text:p'
        enter_p.add_attribute 'text:style-name', 'P9'
        span_enter = Element.new 'text:span'
        # Create a 'big' enter : text:style-name= T12 => '\n\n'
        # For a 'soft' enter : text:style-name=T11 (=> '\n')
        span_enter.add_attribute 'text:style-name', 'T12'
        enter_p.add_element span_enter
        parent[i] = enter_p
      end

      text_p = Element.new 'text:p'
      text_p.add_attribute 'text:style-name', style_p
      span = Element.new 'text:span'
      span.add_attribute 'text:style-name', style_span
      span.text = bloc
      text_p.add_element span
      parent[i+1] = text_p

      i += 2
    end
=begin
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
