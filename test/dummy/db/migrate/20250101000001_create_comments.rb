class CreateComments < ActiveRecord::Migration::Current
  def change
    create_table :comments do |t|
      t.references :post, null: false
      t.text :body
      t.timestamps
    end
  end
end
