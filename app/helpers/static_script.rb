# this script is here to help with generating dates

class StaticScript < Static::ActionView

  @@date_opt = { :alt => _("Choose a date"), :size => '16x16',
    :title => _("Select a date"),
    :onmouseover => "this.className='calendar_over';", :class => 'calendar_out',
    :onmouseout => "this.className='calendar_out';", :style => 'cursor: pointer;'
  }

  @@date_from = nil
  def self.date_from
    @@date_from ||= image_tag('cal.gif', @@date_opt.dup.update(:id => 'date_from'))
  end

  @@date_to = nil
  def self.date_to
    @@date_to ||= image_tag('cal.gif', @@date_opt.dup.update(:id => 'date_to'))
  end

  # used to generate js for calendar. It uses an array of 2 arguments. See
  # link:"http://www.dynarch.com/projects/calendar/"
  #
  # first args : id of input field
  #
  # second args : id of image calendar trigger
  #
  # call it : <%= script_date('date_before', 'date_to') %>
  def self.script_date(*args)
    '<script type="text/javascript">
       Calendar.setup({
        firstDay       :    0,            // first day of the week
        inputField     :    "%s", // id of the input field
        button         :    "%s",  // trigger for the calendar (button ID)
        align          :    "Tl",         // alignment : Top left
        singleClick    :    true,
             ifFormat       : "%%Y-%%m-%%d"  // our date only format
         });
   </script>' % args
  end

end
