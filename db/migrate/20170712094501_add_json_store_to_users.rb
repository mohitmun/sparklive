class AddJsonStoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :json_store, :json
  end
end
