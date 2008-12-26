require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  fixtures :workflows

  def test_to_strings
    check_strings Workflow
  end

  def test_allowed_status
    Workflow.all.each do |w|
      w.allowed_status.each do |s|
        assert_instance_of Statut, s
      end
    end
  end
end
