class CreateCallParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :call_participants do |t|
      t.references :call, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :joined_at, null: false
      t.datetime :left_at
      t.timestamps
    end

    add_index :call_participants, [ :call_id, :user_id, :left_at ], name: "idx_call_participants_active"
  end
end
