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
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

 # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all


  # Add more helper methods to be used by all tests here...

  def login(login, password)
    controller = @controller
    @controller = AccountController.new
    post :login, :user_login => login, :user_password => password,
      :user_crypt => 'false'
    @controller = controller
  end

  def logout
    controller = @controller
    @controller = AccountController.new
    post :logout
    @controller = controller
  end

  def submit_with_name(object, value)
    form = select_form 'main_form'
    form.send(object).name = value
    form.submit
  end

  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
  def uploaded_png(path, filename=nil)
    uploaded_file(path, 'image/png', filename)
  end
  def uploaded_gif(path, filename=nil)
    uploaded_file(path, 'image/gif', filename)
  end

  # Call it like this :
  #   check_ajax_filter :severite_id, 2, :requests
  # For testing an ajax filters for "severite_id" field on
  # assigns(:requests) collection, with a value of 2 for each of'em
  def check_ajax_filter(attribute, value, collection_index)
    xhr :get, :index, :filters => { attribute => value }
    assert_response :success
    assigns(collection_index).each { |elt| assert_equal elt[attribute], value }
  end

  # Check the validity of the ids with the klass
  # call it like this : check_ids(@client.contract_ids, Contract)
  def check_ids(ids, klass)
    assert ids.is_a?(Array)
    ids.each { |i|
      assert_kind_of Integer, i
      assert klass.find(i)
    }
  end

  # List of all common methods used on an ActiveRecord to display (a part) of it
  StringMethods = [ :to_s, :name, :to_param, :name_clean,
                    :updated_on_formatted, :created_on_formatted
                  ] unless defined? StringMethods

  # Will call all common methods involved with strings on all instance of the klass
  # You can add specific methods.
  # Ex : check_strings(Document, :date_delivery_on_formatted)
  # => will call all StringMethods and the additionnal date_delivery_on_formatted
  def check_strings(klass, *methods)
    klass.find(:all).each { |o|
      StringMethods.each { |m|
        begin
          assert !o.send(m).blank? if o.respond_to? m
        rescue Exception => e
          raise Exception.new("check strings failed on #{m} for an #{klass} (#{o.id})")
        end
      }
      methods.each {|m|
        begin
          assert !o.send(m).blank?
        rescue Exception => e
          raise Exception.new("check strings failed on #{m} for an #{klass} (#{o.id})")
        end

      }
    }
  end


  ArrayMethods = [ :content_columns ] unless defined? ArrayMethods
  # Will call all common methods involved with arrays
  # You can add specific methods.
  # Ex : check_strings(Request, :remanent_fields)
  # => will call all ArrayMethods and the additionnal remanent_fields
  # Note : All test methods are instance ones.
  def check_arrays(klass, *methods)
    ArrayMethods.each { |m|
      begin
        assert !klass.send(m).empty? if klass.respond_to? m
      rescue Exception => e
        raise Exception.new("check arrays failed on #{m} for model #{klass}")
      end
    }
    methods.each { |m|
      begin
        assert !klass.send(m).empty?
      rescue Exception => e
        raise Exception.new("check arrays failed on #{m} for model #{klass}")
      end
    }
  end

end
