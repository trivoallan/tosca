class Elapsed < ActiveRecord::Base
  belongs_to :demande

  # Ctor, which ask for the depending request and rule
  # Call it like this : Elapsed.new(@request)
  def initialize(request)
    super(:demande => request, :until_now => 0)
  end

  # self-update with a comment
    # Please ensure that add() and remove() are consistent
  def add(comment)
    self.until_now += comment.elapsed

    if !self.taken_into_account? && comment.statut_id == 2
      self.taken_into_account = self.until_now
    end
    # Some shortcuts can be taken within the status model. for memo :
    # 5 Bypassed        6 Fixed
    # 7 Closed          8 Cancelled
    if !self.workaround? && [ 5, 6, 7, 8 ].include?(comment.statut_id)
      self.workaround = self.until_now
    end
    if !self.correction? && [ 6, 7, 8 ].include?(comment.statut_id)
      self.correction = self.until_now
    end

    save
  end

  # called when the comment is destroyed.
  # Please ensure that add() and remove() are consistent
  # TODO : fix this buggy method : what if there
  # is 2 comments for the same status ?
  def remove(comment)
    self.until_now -= comment.elapsed

    if self.taken_into_account? && comment.statut_id == 2
      self.taken_into_account = nil
    end
    if self.workaround? && comment.statut_id == 5
      self.workaround = nil
    end
    if self.correction? && comment.statut_id == 6
      self.correction = nil
    end

    save
  end

  # Overloaded in order to be consistent :
  # When there is a value of 0, it's been taken into account
  def taken_into_account?
    !read_attribute(:taken_into_account).nil?
  end

  def taken_into_account
    compute_value :taken_into_account, Statut::Active
  end

  def workaround
    compute_value :workaround, Statut::Bypassed
  end

  def correction
    compute_value :correction, Statut::Fixed
  end

  def taken_into_account_progress
    request = self.demande
    # 1 hour = 1/24 of a day
    progress(taken_into_account, (1/24.0), request.interval)
  end

  def workaround_progress
    request = self.demande
    commitment = request.commitment
    return 0.0 unless commitment
    progress(self.workaround(), commitment.contournement, request.interval)
  end

  def correction_progress
    request = self.demande
    commitment = request.commitment
    return 0.0 unless commitment
    progress(self.correction(), commitment.correction, request.interval)
  end

  # TODO
  def to_s
    '-'
  end

  # Convert a time relative to a commitment into an absolute time
  def self.relative2absolute(elapsed, interval)
    (elapsed / interval.hours).days
  end

  # Compute progress from an 'elapsed' time in "interval" reference,
  # with 'commitment' day
  def progress(elapsed, commitment, interval)
    return -1 if commitment == -1
    elapsed / (commitment * interval).hours
  end

  private
  def compute_value(value, statut_id)
    value = read_attribute(value)
    return value unless value.nil?

    request = self.demande
    result = self.until_now
    return result unless request.time_running?
    current = Commentaire.new(:created_on => Time.now, :statut_id => request.statut_id)
    last = request.last_status_comment
    contract = request.contract
    result += contract.rule.compute_between(last, current, contract)
  end


end
