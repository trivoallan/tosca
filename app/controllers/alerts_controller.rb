class AlertsController < ApplicationController

  def on_submit

  end

  def ajax_on_submit
    render :partial => 'ajax_on_submit'
  end

end
