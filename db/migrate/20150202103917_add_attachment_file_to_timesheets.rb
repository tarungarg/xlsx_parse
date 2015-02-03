class AddAttachmentFileToTimesheets < ActiveRecord::Migration
  def self.up
    change_table :timesheets do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :timesheets, :file
  end
end
