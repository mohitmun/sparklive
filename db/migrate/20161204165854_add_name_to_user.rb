class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean
    add_column :users, :name, :text
  end
end
