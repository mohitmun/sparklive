class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :room_id
      t.text :person_id
      t.json :json_store
      t.text :text
      t.text :html
      t.text :remote_id

      t.timestamps null: false
    end
  end
end
