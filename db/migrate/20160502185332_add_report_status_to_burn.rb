class AddReportStatusToBurn < ActiveRecord::Migration
  def change
    add_column :burns, :report_status, :boolean
  end
end
