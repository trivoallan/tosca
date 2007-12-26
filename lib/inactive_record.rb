# This small module implements utils for
# ActiveRecord with this notion of "inactive", which
# allows to keep a desactived record.
module InactiveRecord
  def strike(attribute)
    value = read_attribute(attribute)
    return "<strike>#{value}</strike>" if read_attribute(:inactive)
    value
  end
end
