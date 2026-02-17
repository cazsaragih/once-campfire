class AddAutoPresenceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :manually_away, :boolean, default: false, null: false
    add_column :users, :active_connections, :integer, default: 0, null: false
  end
end
