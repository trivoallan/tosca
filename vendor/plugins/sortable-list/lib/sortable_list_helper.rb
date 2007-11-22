require 'hash_ext'
module SortableListHelper

  # To use simply put this in your table header
  #
  #     <th><%=s :first_name%></th>
  #
  # This will create markup that looks like the following:
  #
  #     <th><a href="?sort=first_name%20ASC">First Name</a></th>
  #
  # Then in your controller just do:
  #
  #     @users = User.find :all, :order => params[:sort]
  #
  # If the current field is the field being sorted then it will do the opposite
  # direction. So if the user clicked the link for the past request then the
  # same code will now generate
  #
  #     <th><a href="?sort=first_name%20DESC">First Name</a></th>
  #
  # This allows users to reverse the order simply by clicking the link again.
  # In addition sortable_header method takes a option hash as the second
  # argument with the following valid options:
  #
  # label::
  #   If humanize is not guessing your field name correctly you can use this to
  #   give an explicit label.
  # descend::
  #   Set to true if you want this column to initially be decending. Date
  #   columns are often used in this way.
  # default::
  #   Set to true if this column is the default sort column. This means that if
  #   the :sort param has no value this column assumes it is sorting the data.
  #   You should specify one column with default => true
  # asc_img::
  #   The name of an image to show beside the column if we are sorting in an
  #   assending order (this should probably be a down arrow).
  # desc_img::
  #   The name of an image to show beside the column if we are sorting in a
  #   descending order (this should probably be a up arrow).
  #
  # Since you most likely do not want to specify a asc_img and desc_img on every
  # execution of the sortable_header method you can also define the following
  # constants so the images are automatically included without explicit
  # specification
  #
  # * SORTABLE_COLUMN_ASC
  # * SORTABLE_COLUMN_DESC
  #
  # NOTE: This method is aliased as #s for easy programming much like
  # the #h method which escapes #html_escape
  def sortable_header(field, options={})
    dir = 'ASC'
    dir = 'DESC' if options[:descend]
    fld = field.to_s

    cur = nil
    cur = "#{fld} #{dir}" if options[:default]
    cur = @sort || params[:sort] unless (@sort || params[:sort]).blank?
    if cur
      cur_fld, cur_dir = cur.split(/\s*,\s*/).first.split /\s+/
      dir = cur_dir == 'ASC' ? 'DESC' : 'ASC' if cur_fld == fld
    end

    label = options[:label] || fld.titleize

    asc_img = desc_img = ''
    if cur_fld == fld
      asc_img = SORTABLE_COLUMN_ASC if Object.const_defined? 'SORTABLE_COLUMN_ASC'
      desc_img = SORTABLE_COLUMN_DESC if Object.const_defined? 'SORTABLE_COLUMN_DESC'
      asc_img = options[:asc_img] || asc_img
      desc_img = options[:desc_img] || desc_img
    end
    img = dir == 'ASC' ? asc_img : desc_img
    img = image_tag(img, :alt => '', :border => 0) + ' ' unless img.blank?

    args = params.merge :sort => "#{fld} #{dir}"
    args.delete_if {|k, v| %w(controller action).include? k}
    link_to (img+label), '?'+args.to_qs
  end
  alias_method :s, :sortable_header
end
