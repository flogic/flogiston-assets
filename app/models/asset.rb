class Asset < ActiveRecord::Base
  has_attached_file :data
  
  validates_uniqueness_of :handle, :allow_blank => true
  
  before_create :set_default_handle
  
  
  private
  
  def set_default_handle
    self.handle = data_file_name if self.handle.blank?
  end
end
