class AttachmentsController < ApplicationController
  def index
    @attachment_pages, @attachments = paginate :attachments, :per_page => 10,
    :include => [:commentaire]
  end

  def show
    @attachment = Attachment.find(params[:id])
  end

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
      flash[:notice] = 'Attachment was successfully created.'
      redirect_to attachment_path(@attachment)
    else
      render :action => 'new'
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
  end

  def update
    @attachment = Attachment.find(params[:id])
    if @attachment.update_attributes(params[:attachment])
      flash[:notice] = 'Attachment was successfully updated.'
      redirect_to attachment_path(@attachment)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Attachment.find(params[:id]).destroy
    redirect_to attachments_path
  end

end
