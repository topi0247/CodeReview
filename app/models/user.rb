# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  avatar_url :string           not null
#  name       :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_uid  (uid) UNIQUE
#
class User < ApplicationRecord
  has_many :review_logs, dependent: :destroy
  has_many :review_contents, through: :review_logs
  validates :name, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :avatar_url, presence: true
end
