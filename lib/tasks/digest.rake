namespace :tosca do
  namespace :digest do

    desc "Send mails for the digests"
    #We specify => :environment to have Rails env in our task
    task :send_mails => :environment do
      require 'scope'

      include Scope
      include DigestReporting

      now = Time.now

      # We send the digest on the morning of the next day

      isMonday = ( now.wday == 1 )
      isSunday = ( now.wday == 0 )
      isEndMonth = ( now.last_month.end_of_month == now.yesterday )

      User.find(:all).each do |u|
        define_scope(u, true) do
          #Send emails eveyday except fior Saturdays and Sundays
          if u.prefers_digest_daily? and not isSunday and not isMonday
            digest_managers("day")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          #Send emails for the week
          if u.prefers_digest_weekly? and isMonday
            digest_managers("week")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

          #Send emails for the month
          if u.prefers_digest_monthly? and isEndMonth
            digest_managers("month")
            Notifier::deliver_reporting_digest(u, @result, @period, now)
          end

        end
      end
    end

  end
end
