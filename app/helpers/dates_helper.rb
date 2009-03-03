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

#For the calendar helper
require 'calendar_grid'

#To have Monday as the start day of week
CalendarGrid::Builder.start_wday = 1

module DatesHelper

  def pretty_date(date)
    day = sprintf("%02d", date.day)
    month = _(date.strftime("%b"))

    result = ""
    result << '<div class="datestamp">'
    result << '<div>'
    result << "<span class=\"cal1 cal1x\">#{month}</span>"
    result << "<span class=\"cal2\">#{day}</span>"
    result << "<span class=\"cal3\">#{date.year}</span>"
    result << '</div>'
    result << '</div>'
  end

  def complete_date(date)
    result = _(date.strftime("%A"))            #day of the week : Monday
    result << " "
    result << date.strftime("%d")              #day of the month : 10
    result << " "
    result << _(date.strftime("%B"))           #month : December
    result << " "
    result << date.strftime("%Y")              #Year : 2007
  end

  # Display a BIG calendar for the month of the date in param
  #
  # options :
  #   :title Display a title for the calendar
  def calendar_month(date, options = {})
    cal = CalendarGrid.build(date, 1)

    #We limit to one year and one month
    year = cal.years.first
    month = year.months.first

    result = %(<div class="big_calendar">)
    result << %(<table class="big_calendar" cellspacing="0">)
    if options.has_key? :title
      result << %(<caption class="month_caption">#{options[:title]}</caption>)
    end
    result << %(<th width="14%" class="weekdays">#{_('Monday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Tuesday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Wednesday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Thursday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Friday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Saturday')}</th>)
    result << %(<th width="14%" class="weekdays">#{_('Sunday')}</th>)
    month.weeks.each do |week|
      result << %(<tr class="events">)
      week.each do |day|
        if day.proxy?
          result << %(<td valign="top" class="big_calendar_events" style="background-color:#E8E8E8;"></td>)
        else
          result << %(<td valign="top" class="big_calendar_events">)
          result << %(<div class="big_calendar_date">#{day.strftime("%d")}<br/></div>)
          result << %(<div class="holidays">)
          #We call to_s to make it work even with nil values
          result << yield(day.date).to_s if block_given?
          result << %(</div><br/></td>)
        end
      end
      result << %(</tr>)
    end
    result << %(</table></div>)
  end

  # Display a BIG calendar for the week of the date in param
  #
  #
  #
  def calendar_weekly(start_date, options = {}, &block)
    block ||= Proc.new { |d| nil }
    defaults = {
      :table_class => 'week-view',
      :start_time => 8,
      :end_time => 19,
      :duration => 30
    }
    options = defaults.merge options

    time_range = (options[:start_time]..options[:end_time]).to_a

    cal = "<table class=\"#{options[:table_class]}\">"
    cal << '<thead><tr>'
    week = start_date.strftime(_('W%W %Y'))
    cal << "<th><h3>#{week}</h3></th>"
    5.times do |d|
      date = start_date.beginning_of_day + d.days
      cal << "<th><h3>#{date.strftime('%a %d/%m')}</h3></th>"
    end
    cal << '</tr></thead><tbody>'
    time_range.each do |hour|
      minutes = 0
      number_division = (60/options[:duration])
      number_division.times do |i|
        print_minutes = minutes.to_s.rjust(2, '0')
        cal << "<tr class=\"m#{print_minutes} d#{options[:duration]}\">"
        cal << "<th rowspan=\"#{number_division}\"><h2>#{hour.to_s.rjust(2, '0')}:00</h2></th>" if i == 0
        5.times do |d|

          # cell_attrs should return a hash.
          now = start_date.beginning_of_day +
            d.day + hour.hour + minutes.minutes
          cell_text, cell_attrs = block.call(now)
          cell_text ||= ''
          cell_attrs ||= {}
          cell_attrs[:class] = cell_attrs[:class].to_s + ' today' if Time.today == d
          cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(' ')

          cal << "<td #{cell_attrs}>#{cell_text}</td>"
        end
        minutes += options[:duration]
        cal << '</tr>'
      end
    end
    cal << '</tbody></table>'
  end

end
