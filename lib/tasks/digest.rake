namespace :tosca do
  namespace :digest do

    desc "Send mails for the digests"
    #We specify => :environment to have Rails env in our task
    task :send_mails => :environment do
      require 'scope_system'

      include Scope
      include DigestReporting

      now = Time.now
      #Is tomorrow the first day of the next week ?
      #If yes, we are Sunday
      #The wday method is not safe (why Sunday.wday == 0 ???)
      #isSunday = ( (now + 1.day) == (now + 1.week).beginning_of_week )
      isSunday = ( now.wday == 0)

      #Is the day after tomorrow the first day of the next week ?
      #If yes, we are Saturday
      #isSaturday = ( (now + 2.day) == (now + 1.week).beginning_of_week )
      isSaturday = ( now.wday == 6)

      isEndMonth = ( now.end_of_month.day == now.day )
      #u = User.find(73)
      User.find(:all).each do |u|
        define_scope(u, true) do
          #Send emails eveyday except Saturdays and Sundays
          if u.prefers_digest_daily? and not isSaturday and not isSunday
            digest_result("day")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          #Send emails on Sundays
          if u.prefers_digest_weekly? and isSunday
            digest_result("week")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          if u.prefers_digest_monthly? and isEndMonth
            digest_result("month")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

        end
      end
    end

  end
end
