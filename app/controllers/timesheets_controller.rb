require "xlsx_parse/xlsx_subsheets"

class TimesheetsController < ApplicationController
  before_action :set_timesheet, only: [:show, :edit, :update, :destroy]
  include XlsxParse

  # GET /timesheets
  # GET /timesheets.json
  def index
    @timesheets = Timesheet.all
  end

  # GET /timesheets/1
  # GET /timesheets/1.json
  def show
  end

  # GET /timesheets/new
  def new
    @timesheet = Timesheet.new
  end

  # GET /timesheets/1/edit
  def edit
  end

  # POST /timesheets
  # POST /timesheets.json
  def create
    @timesheet = Timesheet.new(timesheet_params)

    respond_to do |format|
      if @timesheet.save
        xls = XlsxSubsheets.new
        subsheet_names = xls.divide_into_subsheets(2, 0, @timesheet.file.path, @timesheet.file.updated_at)
        subsheet_names.uniq.each do |path|
          @timesheet.subsheets.build(subsheet_path: path)
          @timesheet.save
        end

        format.html { redirect_to @timesheet, notice: 'Timesheet was successfully created.' }
        format.json { render :show, status: :created, location: @timesheet }
      else
        format.html { render :new }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timesheets/1
  # PATCH/PUT /timesheets/1.json
  def update
    respond_to do |format|
      if @timesheet.update(timesheet_params)
        format.html { redirect_to @timesheet, notice: 'Timesheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @timesheet }
      else
        format.html { render :edit }
        format.json { render json: @timesheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timesheets/1
  # DELETE /timesheets/1.json
  def destroy
    @timesheet.destroy
    respond_to do |format|
      format.html { redirect_to timesheets_url, notice: 'Timesheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download_subsheet
    subsheet = Subsheet.find(params[:id])
    send_file subsheet.subsheet_path, :type=>"application/xls", :x_sendfile=>true
  end

  def download_all_subsheet
    @sheet = Timesheet.find(params[:id])
    dir_name = @sheet.file.updated_at
    zipfile_name = "#{Rails.public_path}/timesheets/#{dir_name}.zip"
    FileUtils.rm zipfile_name if File.exist? zipfile_name
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |z|
      Dir["public/timesheets/#{dir_name}/**/**"].each do |file|
        z.add(file.sub("public/timesheets/#{dir_name}"+'/',''),file)
      end
    end
    send_file zipfile_name, :type=>"application/xls", :x_sendfile=>true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timesheet
      @timesheet = Timesheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def timesheet_params
      params.require(:timesheet).permit(:file)
    end
end
