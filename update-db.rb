connection = Demande.connection.connection
connection.query "UPDATE users SET role_id = 40 WHERE role_id = 2"
connection.query "UPDATE users SET role_id = 2 WHERE role_id = 4"
connection.query "UPDATE users SET role_id = 4 WHERE role_id = 40"
p "roles cleaned"

Demande.find(:all).each{|r| r.reset_elapsed }
p "requests reseted"

classes = [ User, Contrat, Demande ]
classes.each{|c| c.record_timestamps = false }
User.find(:all).each {|u| u.update_attribute :email, 'mloiseleur@linagora.com'}
Contrat.find(:all).each {|c| c.update_attribute :mailinglist, 'mloiseleur@linagora.com' }
Demande.find(:all).each {|d| d.update_attribute :mail_cc, nil }
classes.each{|c| c.record_timestamps = true }
p "emails erased"
