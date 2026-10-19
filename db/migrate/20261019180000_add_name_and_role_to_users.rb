class AddNameAndRoleToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :name, :string
    add_column :users, :role, :integer, null: false, default: 0

    execute <<~SQL
      UPDATE users
      SET name = split_part(email, '@', 1)
      WHERE name IS NULL
    SQL

    change_column_null :users, :name, false
  end

  def down
    remove_column :users, :role
    remove_column :users, :name
  end
end
