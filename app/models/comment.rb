class Comment < ApplicationRecord
  has_ancestry cache_depth: true

  belongs_to :video
  belongs_to :commentator, class_name: 'User'
  belongs_to :parent, class_name: 'Comment', optional: true, inverse_of: :parent
  has_many :subcomments, class_name: 'Comment', foreign_key: :parent_id, inverse_of: :subcomments

  validates_length_of :message, maximum: AppConstants::MAX_COMMENT_MESSAGE_LENGTH
end