class CreatePins < ActiveRecord::Migration[8.2]
  def change
    create_table :pins do |t|
      t.references :message, null: false, foreign_key: true, index: { unique: true }
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
