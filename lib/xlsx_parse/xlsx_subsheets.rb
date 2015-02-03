module XlsxParse
  class XlsxSubsheets
      def divide_into_subsheets(point, bool, timesheet_path = nil, folder_name=nil)
        xls_file = Roo::Excelx.new("#{timesheet_path}")
        date_index = xls_file.first.index("Minutes For")  # Minute For is column of spreedsheet
        total_rows = xls_file.last_row
        dir = "#{Rails.public_path.to_s}/timesheets/#{folder_name}/"
        FileUtils.mkpath(dir) unless File.directory?(dir)
        file_names = []
        Axlsx::Package.new do |p|
          p.workbook.add_worksheet(:name => "TimeSheets") do |sheet|
            sheet.add_row(xls_file.row(1))
            (point..xls_file.last_row).each do |i|
              row_data = xls_file.row(i).map { |o| o.nil? ?  "" : o }
              next_row_data = ((i+1) < total_rows) ? xls_file.row(i+1).map { |o| o.nil? ?  "" : o } : row_data  
              sheet.add_row(row_data)
              next_row_sow = Date.strptime(next_row_data[date_index], "%m/%d/%Y").at_beginning_of_week   #date for begning of the week
              current_date = Date.strptime(row_data[date_index], "%m/%d/%Y")
              timesheet_name = "#{dir}Timesheet (#{next_row_sow}).xlsx"
              File.delete(timesheet_name) if File.exist?(timesheet_name)
              p.serialize(timesheet_name)
              file_names << timesheet_name
              divide_into_subsheets(i+1, 1, timesheet_path, folder_name) if current_date < next_row_sow   #check if date belongs to this week or next week
            end
          end
        end
        return file_names
      end

   end
end