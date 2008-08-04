=begin
  send formatted output directly to the HTTP response
  source : http://wiki.rubyonrails.org/rails/pages/HowtoExportDataAsCSV
  All this controller see the same scheme.
  For a model exported "me", you will have :
  def me :
    which explains will format will be supported and how
  def compute_me :
    which explains will datas will be exported in all of those formats
 All those export finishes with the call to #generate_report,
 which sets correct headers for the differents browser and send the file
=end
class ExportController < ApplicationController

  # return the contents of contributions in a table in ODS format
  # with Ruport :
  # We can export to other formats :
  # compute_contributions(:pdf) export to pdf
  def contributions
    respond_to do |format|
      format.html { redirect_to contributions_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @requests.to_xml should be enough)
      }
      format.ods { compute_contributions(:ods) }
    end
  end

  def compute_contributions(type)
    methods = ['pname_typecontribution', 'pname_logiciel', 'version_to_s',
      'pname_etatreversement', 'delay_in_words', 'clos_enhance',
      'contributed_on_formatted']
    options = { :order => 'contributions.contributed_on ASC',
      :include => [:logiciel, :etatreversement, :demande],
      :conditions => flash[:conditions],
      :methods => methods }

    report = Contribution.report_table(:all, options)
    columns= [ 'id','pname_typecontribution', 'pname_logiciel',
      'version_to_s','pname_etatreversement', 'synthesis',
      'contributed_on_formatted','clos_enhance','delay_in_words' ]
    unless report.column_names.empty?
      report.reorder(columns)
      report.rename_columns columns,
        [ _('id'), _('type'), _('software'), _('version'), _('state'),
          _('summary'), _('reported'), _('closed'), _('delay') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of users in a table in ODS format
  # with Ruport
  def users
    respond_to do |format|
      format.html { redirect_to accounts_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @requests.to_xml should be enough)
      }
      format.ods { compute_users(:ods) }
    end
  end

  def compute_users(type)
    options = { :order => 'users.login', :include =>
      [:recipient,:ingenieur,:role], :conditions => flash[:conditions],
      :methods => ['recipient_client_name', 'role_name']
    }
    report = User.report_table(:all, options)
    columns = ['id','login','name','email','telephone',
      'recipient_client_name', 'role_name']

    report.reorder columns
    report.rename_columns columns,
      [_('id'), _('login'), _('name'), _('e-mail'), _('phone'),
        _('(customer)'), _('roles') ]

    generate_report(report, type, {})
  end

  # with Ruport:
  def phonecalls
    respond_to do |format|
      format.html { redirect_to phonecalls_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @requests.to_xml should be enough)
      }
      format.ods { compute_phonecalls(:ods) }
    end
  end

  def compute_phonecalls(type)
    columns= ['contract_name', 'ingenieur_name', 'recipient_name']
    options = { :order => 'phonecalls.start', :include =>
      [:recipient,:ingenieur,:contract,:demande],
      :conditions => flash[:conditions],
      :methods => columns }
    report = Phonecall.report_table(:all, options)

    columns.push( 'start','end')
    unless report.column_names.empty?
      report.reorder columns
      report.rename_columns columns,
        [ _('Contract'), _('Owner'), _('Customer'), _('Call'),
          _('End of the call') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of a request in a table in  ods
  def requests
    respond_to do |format|
      format.html { redirect_to demandes_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @requests.to_xml should be enough)
      }
      format.ods { compute_demandes(:ods, {}) }
    end
  end

  def compute_demandes(type, options_generate)
    columns = [ 'id', 'logiciels_name', 'clients_name', 'severites_name',
      'created_on_formatted', 'socle', 'updated_on_formatted', 'resume',
      'statuts_name', 'typedemandes_name'
    ]
    options= { :order => 'demandes.created_on', :conditions => flash[:conditions],
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST,
      :methods => columns
     }
    report = nil
    report = Demande.report_table(:all, options)
    unless report.column_names.empty?
      report.reorder columns
      report.rename_columns columns,
       [ _('Id'), _('Software'), _('Customer'), _('Severity'),
         _('Submission date') , _('Platform'), _('Last update'),
         _('Summary'), _('Status'), _('Type') ]
    end

    generate_report(report, type, options_generate)
  end


  MIME_EXTENSION = {
    :text => [ '.txt', 'text/plain' ],
    :csv  => [ '.csv', 'text/csv' ],
    :pdf  => [ '.pdf', 'application/pdf' ],
    :html => [ '.html', 'text/html' ],
    :ods  => [ '.ods', 'application/vnd.oasis.opendocument.spreadsheet']
  }

  # Generate and upload a report to the user with a predefined name.
  #
  # Usage : generate_report(report, :csv) with report a Ruport Data Table
  def generate_report(report, type, options)
    #to keep the custom filters before the export :
    flash[:conditions] = flash[:conditions]
    file_extension = MIME_EXTENSION[type].first
    content_type = MIME_EXTENSION[type].last
    prefix = ( @recipient ? @recipient.client.name : 'OSSA' )
    suffix = Time.now.strftime('%d_%m_%Y')
    filename = [ prefix, params[:action], suffix].join('_') + file_extension

     #this is required if you want this to work with IE
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers['Content-type'] = content_type
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0"
     else
       headers["Content-type"] ||= content_type
       headers['Pragma'] = 'public'
       headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
     end
    report_out = report.as(type, options)
    render(:text =>report_out , :layout => false)
  end

  #export the comex table in ods
  def comex
    clients = flash[:clients]
    requests= flash[:requests]
    total = flash[:total]
    data = []
    row = ['', _('To be closed')+ " (I)",'','','',
      _('New requests'),'','','',
      _("Requests closed \n this week") + ' (IV)','','','',
      _("Total in progress \n end week") + ' (V=I+III-IV)','','','',
      _('TOTAL')
    ]
    data << row
    row = [_('Customer')]
    4.times do
      row += [_('Blocking'), _('Major'), _('Minor'), _('None')]
    end
    row << _('To close')
    data << row
    clients.each do |c|
      name = c.name.intern
      row = [name]
      repeat4times row,requests[:last_week][name],1
      repeat4times row,requests[:new][name],1
      repeat4times row,requests[:closed][name],1
      repeat4times row, total[:active][name],0
      row << total[:final][name]
      data << row
    end

    row = [_('TOTALS')]
    repeat4times row, requests[:last_week][:total],0
    repeat4times row, requests[:new][:total],0
    repeat4times row, requests[:closed][:total],0
    repeat4times row, total[:active][:total],0
    row << total[:final][:total]
    data << row

    report =  Table(:column_names => data[1], :data => data[2..-1])
    generate_report(report, :ods, {})

    flash[:clients]= flash[:clients]
    flash[:requests]= flash[:requests]
    flash[:total]= flash[:total]
  end

  private
  def repeat4times( row, element, decalage)
    4.times do |i|
      row << element[i+decalage].to_i
    end
  end

  # TODO : le mettre dans les utils ?
  def pname(object)
    (object ? object.name : '-')
  end

end
