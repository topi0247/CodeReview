# == Schema Information
#
# Table name: review_logs
#
#  id              :bigint           not null, primary key
#  repository_name :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_review_logs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ReviewLog < ApplicationRecord
  belongs_to :user
  has_many :review_contents, dependent: :destroy
  validates :repository_name, presence: true
end
