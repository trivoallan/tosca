#!/bin/bash -x

mysql="mysql tosca"

echo "UPDATE schema_info SET version = 1" | $mysql

RAILS_ENV=production rake db:migrate

# Swap role_id to the new model.
# old client (2) => customer(4)
# old ossa (4) => manager (2)
echo "UPDATE users SET role_id = 40 WHERE role_id = 2" | $mysql
echo "UPDATE users SET role_id = 2 WHERE role_id = 4" | $mysql
echo "UPDATE users SET role_id = 4 WHERE role_id = 40" | $mysql


echo "ActiveRecord::Base.record_timestamps = false; Demande.find(:all).each{|r| r.reset_elapsed }; ActiveRecord::Base.record_timestamps = true" | RAILS_ENV=production ./script/console
