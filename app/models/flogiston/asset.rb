class Flogiston::Asset < ActiveRecord::Base
  has_attached_file :data

  validates_uniqueness_of :handle, :allow_blank => true

  before_create :set_default_handle

  def contents
    return if new_record?
    return unless data.file?

    data.to_file.read
  end


  private

  def set_default_handle
    self.handle = data_file_name if self.handle.blank?
  end
end
