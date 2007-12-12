class TimeTicketsController < ApplicationController
  def index
    @time_ticket_pages, @time_tickets = paginate :time_tickets, :per_page => 10
  end

  def show
    @time_ticket = TimeTicket.find(params[:id])
  end

  def new
    @time_ticket = TimeTicket.new
  end

  def create
    @time_ticket = TimeTicket.new(params[:time_ticket])
    if @time_ticket.save
      flash[:notice] = _("'%s' was successfully created.") % @time_ticket.name
      redirect_to time_tickets_path
    else
      render :action => 'new'
    end
  end

  def edit
    @time_ticket = TimeTicket.find(params[:id])
  end

  def update
    @time_ticket = TimeTicket.find(params[:id])
    if @time_ticket.update_attributes(params[:time_ticket])
      flash[:notice] = _("'%s' was successfully updated.") % @time_ticket.name
      redirect_to time_ticket_path(@time_ticket)
    else
      render :action => 'edit'
    end
  end

  def destroy
    TimeTicket.find(params[:id]).destroy
    redirect_to time_tickets_path
  end
end
