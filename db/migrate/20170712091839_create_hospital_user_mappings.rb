class CreateHospitalUserMappings < ActiveRecord::Migration
  def change
    create_table :hospital_user_mappings do |t|
      t.integer :hospital_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
