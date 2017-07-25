class CreateVisitorRooms < ActiveRecord::Migration
  def change
    create_table :visitor_rooms do |t|
      t.text :name
      t.text :visitor_room_id
      t.json :json_store

      t.timestamps null: false
    end
  end
end
