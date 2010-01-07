class AddHandleForAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :handle, :string
  end

  def self.down
    remove_column :assets, :handle
  end
end
