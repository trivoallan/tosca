module NewsHelper
  def box_news(label, options = nil)
    @elements = New.find(:all, :select => 'id,subject')
    @elements.collect!{ |n| [ n.subject, n.id ] }

    select_tag label, options_for_select(@elements), options
  end
end
