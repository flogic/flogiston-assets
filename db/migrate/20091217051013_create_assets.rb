class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets, :force => true do |t|
      t.string  :data_file_name
      t.string  :data_content_type
      t.integer :data_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
