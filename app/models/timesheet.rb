class Timesheet < ActiveRecord::Base
  has_many :subsheets, dependent: :destroy
  has_attached_file :file
  validates_attachment_content_type :file, content_type: %w(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel)
end
