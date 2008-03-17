class Elapsed < ActiveRecord::Base
  belongs_to :demande

  # Ctor, which ask for the depending request and rule
  # Call it like this : Elapsed.new(@request, @request.contrat.rule)
  def initialize(request, rule)
    super(:demande => request, :until_now => rule.elapsed_on_create)
  end

  # self-update with a comment
    # Please ensure that add() and remove() are consistent
  def add(comment)
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

  # called when the comment is destroyed.
  # Please ensure that add() and remove() are consistent
  def remove(comment)
    self.until_now -= comment.elapsed

    if !self.taken_into_account.nil? && comment.statut_id == 2
      self.taken_into_account = nil
    end
    if !self.workaround.nil? && comment.statut_id == 5
      self.workaround = nil
    end
    if !self.correction.nil? && comment.statut_id == 6
      self.correction = nil
    end

    save
  end

  def taken_into_account
    read_attribute(:taken_into_account) || 0
  end

  def workaround
    read_attribute(:workaround) || 0
  end

  def correction
    read_attribute(:correction) || 0
  end


  def progress(elapsed, commitment, interval)
    elapsed / (commitment * interval).hours
  end

  # TODO
  def to_s
    '-'
  end
end
