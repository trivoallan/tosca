class Elapsed < ActiveRecord::Base
  belongs_to :demande

  # self-update with a comment
  def update_with(comment)
    self.until_now += comment.elapsed

    if self.taken_into_account.nil? && comment.statut_id == 2
      self.taken_into_account = self.until_now
    end
    if self.workaround.nil? && comment.statut_id == 5
      self.workaround = self.until_now
    end
    if self.correction.nil? && comment.statut_id == 6
      self.correction = self.until_now
    end

    save
  end

  def to_s
    '-'
  end
end
