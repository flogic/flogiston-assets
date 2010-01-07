class Asset < ActiveRecord::Base
  has_attached_file :data
  
  validates_uniqueness_of :handle, :allow_blank => true
end
