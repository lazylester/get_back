class AddNotificationColumnToGlacierArchives < ActiveRecord::Migration[5.0]
  def change
    add_column :glacier_archives, :notification, :json
  end
end
