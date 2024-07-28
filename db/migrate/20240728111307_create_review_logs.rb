class CreateReviewLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :review_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :repository_name, null: false
      t.timestamps
    end
  end
end
