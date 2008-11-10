#
# Copyright (c) 2006-2008 Linagora
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
# Settings specified here will take precedence over those in config/environment.rb

# The mail environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true
config.cache_store = :memory_store

#We only need model and mails
config.frameworks = [:action_mailer, :active_record]

config.log_level = :info


# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false


# View Optimization : no '\n'
ActionView::Base.erb_trim_mode = '>'
