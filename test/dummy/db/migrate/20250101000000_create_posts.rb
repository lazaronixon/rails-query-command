class CreatePosts < ActiveRecord::Migration::Current
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
