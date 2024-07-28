class CreateReviewContents < ActiveRecord::Migration[7.1]
  def change
    create_table :review_contents do |t|
      t.references :review_log, null: false, foreign_key: true
      t.string :file_path, null: false
      t.string :commit_oid, null: false
      t.json :content, null: false
      t.timestamps
    end
  end
end
