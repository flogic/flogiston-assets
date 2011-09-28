class Flogiston::Asset < ActiveRecord::Base
  has_attached_file :data

  validates_uniqueness_of :handle, :allow_blank => true

  before_create :set_default_handle

  def contents
    return if new_record?
    return unless data.file?

    data.to_file.read
  end

  def contents=(val)
    return if new_record?
    return unless data.file?
    return if data.dirty?

    File.open(data.path, 'w') do |f|
      f.print val
    end
    self.data_file_size = val.length
  end

  private

  def set_default_handle
    self.handle = data_file_name if self.handle.blank?
  end
end
