#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# this script is here to help with generating dates

class StaticScript < Static::ActionView

  @@date_opt = { :size => '16x16',
    :onmouseover => "this.className='calendar_over';", :class => 'calendar_out',
    :onmouseout => "this.className='calendar_out';", :style => 'cursor: pointer;'
  }

  def self.date_from
    options = { :alt => _("Choose a date"),
      :title => _("Select a date"), :id => 'date_from' }
    image_tag('icons/cal.gif', @@date_opt.dup.update(options))
  end

  def self.date_to
    options = { :alt => _("Choose a date"),
      :title => _("Select a date"), :id => 'date_from' }
    image_tag('icons/cal.gif', @@date_opt.dup.update(options))
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
