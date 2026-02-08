class AddAvailabilityToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :availability, :integer, default: 0, null: false
  end
end
