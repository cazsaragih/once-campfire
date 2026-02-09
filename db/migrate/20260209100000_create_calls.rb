class CreateCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :calls do |t|
      t.references :room, null: false, foreign_key: true
      t.references :initiator, null: false, foreign_key: { to_table: :users }
      t.string :livekit_room_name, null: false
      t.string :status, null: false, default: "active"
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.timestamps
    end

    add_index :calls, [:room_id, :status]
    add_index :calls, :livekit_room_name, unique: true
  end
end
