class CreateSubsheets < ActiveRecord::Migration
  def change
    create_table :subsheets do |t|
      t.string :subsheet_path
      t.integer :timesheet_id

      t.timestamps null: false
    end
  end
end
