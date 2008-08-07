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
  
end
