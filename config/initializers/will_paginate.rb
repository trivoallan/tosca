WillPaginate::ViewHelpers.pagination_options[:renderer] = ToscaRenderer
module WillPaginate::ViewHelpers
  def page_entries_info(collection)
    if collection.total_pages < 2
      case collection.size
      when 0; _('No entries found')
      when 1; _('Displaying <b>1</b> entry')
      else;   _("Displaying <b>all %d</b> entries") % collection.size
      end
    else
      _('Displaying entries <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> in total') % [
         collection.offset + 1,
         collection.offset + collection.length,
         collection.total_entries
       ]
    end
  end
end
