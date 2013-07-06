class AddLicenceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :licence, :string
  end
end
