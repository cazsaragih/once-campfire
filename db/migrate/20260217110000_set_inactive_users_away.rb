class SetInactiveUsersAway < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE users SET availability = 1 WHERE active_connections = 0 AND availability = 0 AND manually_away = 0
    SQL
  end

  def down
    # Not reversible — can't know which users were previously online
  end
end
