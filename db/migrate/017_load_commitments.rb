class LoadCommitments < ActiveRecord::Migration
  class Engagement < ActiveRecord::Base; end

  def self.up
    # Do not erase existing Commitments
    return unless Engagement.count == 0

    # Sample commitments
    blocking, major, minor, none = 1, 2, 3, 4
    information, issue = 1, 2

    add_commitment = Proc.new do |severity_id, typerequest_id, workaround, fix|
      attr = { :severite_id => severity_id, :typedemande_id => typerequest_id,
        :correction => fix, :contournement => workaround }
      Engagement.create(attr)
    end

    add_commitment.call(blocking, issue, 0.16, 5)
    add_commitment.call(major, issue, 5, 20)
    add_commitment.call(minor, issue, 5, -1)

    add_commitment.call(blocking, information, -1, 1)
    add_commitment.call(major, information, -1, 1)
    add_commitment.call(minor, information, -1, 1)
  end

  def self.down
    Engagement.find(:all).each{ |e| e.destroy }
  end
end
