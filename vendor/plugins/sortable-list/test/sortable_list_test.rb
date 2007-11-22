$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'cgi'

class SortableListTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include SortableListHelper

  attr_accessor :params

  def setup
    @controller = self
    self.params = {}
  end

  def test_normal_column
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>', s(:first_name)
  end

  def test_desc_column
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>',
      s(:first_name, :descend => true)
  end

  def test_default_column
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>',
      s(:first_name, :default => true)
  end

  def test_params_override_default
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>',
      s(:first_name, :default => true)
  end

  def test_default_and_desc_column
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>',
      s(:first_name, :default => true)
  end

  def test_current_asc
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>', s(:first_name)
  end

  def test_current_desc
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>', s(:first_name)
  end

  def test_label
    assert_equal '<a href="?sort=first_name+ASC">First</a>',
      s(:first_name, :label => 'First')
  end

  def test_specified_image
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC"><img alt="" border="0" src="/images/down.png" /> First Name</a>',
      s(:first_name, :asc_img => 'down', :desc_img => 'up')
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC"><img alt="" border="0" src="/images/up.png" /> First Name</a>',
      s(:first_name, :asc_img => 'down', :desc_img => 'up')
  end

  def test_image_constants
    Object.const_set 'SORTABLE_COLUMN_ASC', 'down'
    Object.const_set 'SORTABLE_COLUMN_DESC', 'up'

    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC"><img alt="" border="0" src="/images/down.png" /> First Name</a>',
      s(:first_name)
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC"><img alt="" border="0" src="/images/up.png" /> First Name</a>',
      s(:first_name)

    Object.send :remove_const, 'SORTABLE_COLUMN_ASC'
    Object.send :remove_const, 'SORTABLE_COLUMN_DESC'
  end

  def test_image_specifications_have_priority
    Object.const_set 'SORTABLE_COLUMN_ASC', 'down'

    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC"><img alt="" border="0" src="/images/up.png" /> First Name</a>',
      s(:first_name, :asc_img => 'up')

    Object.send :remove_const, 'SORTABLE_COLUMN_ASC'
  end

  # Simulate url_for so link_to works
  def url_for(options)
    '?' + options.collect do |key, value|
      "#{key}=#{CGI.escape value}"
    end.join('&')
  end

  # So image_tag works
  def request
    self
  end

  def relative_url_root
    ''
  end
end
