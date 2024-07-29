# == Schema Information
#
# Table name: review_contents
#
#  id            :bigint           not null, primary key
#  commit_oid    :string           not null
#  content       :json             not null
#  file_path     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  review_log_id :bigint           not null
#
# Indexes
#
#  index_review_contents_on_review_log_id  (review_log_id)
#
# Foreign Keys
#
#  fk_rails_...  (review_log_id => review_logs.id)
#
class ReviewContent < ApplicationRecord
  belongs_to :review_log

  validates :file_path, presence: true
  validates :commit_oid, presence: true
  validates :content, presence: true
end
