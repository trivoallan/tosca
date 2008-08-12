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
  
end
