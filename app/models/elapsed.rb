class Elapsed < ActiveRecord::Base
  belongs_to :demande

  def to_s
    '-'
  end
end
