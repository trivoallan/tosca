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
      isSunday = ( (now + 1.day) == (now + 1.week).beginning_of_week )

      #Is tomorrow the first day of a month ?
      #If yes, we are the last day of a month
      isEndMonth = ( (now + 1.day).day == 1 )
#      u = User.find(73)
       User.find(:all).each do |u|
        define_scope(u, true) do
          if u.prefers_digest_daily?
            digest_result("day")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          #Send emails on Sundays
          if u.prefers_digest_weekly? and isSunday
            digest_result("week")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          #Is tomorrow the first day of a month ?
          #If yes, we are the last day of a month
          if u.prefers_digest_monthly? and isEndMonth
            digest_result("month")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

        end
      end
    end

  end
end
