class AddJsonSHospital < ActiveRecord::Migration
  def change
    add_column :hospitals, :json_store, :json
  end
end
