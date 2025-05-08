class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.text :content, null: false
      t.string :assignment_type, null: false
      t.json :result
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
