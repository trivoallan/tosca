class MoveAttachmentIdFromCommentToCommentIdInAttachment < ActiveRecord::Migration
  class Comment < ActiveRecord::Base
    belongs_to :attachment
  end

  class Attachment < ActiveRecord::Base
    has_one :comment
  end

  def self.up
    add_column :attachments, :comment_id, :integer

    Attachment.all.each do |a|
      a.update_attribute(:comment_id, a.comment.id)
    end

    remove_column :comments, :attachment_id
  end

  def self.down
    add_column :comments, :attachment_id, :integer

    Attachment.all.each do |a|
      a.comment.update_attribute(:attachment_id, a.id)
    end

    remove_column :attachments, :comment_id
  end
end
