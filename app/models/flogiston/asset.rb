class Flogiston::Asset < ActiveRecord::Base

  ATTACHED_FILE_OPTIONS = { :storage => :filesystem }
  if Object.const_defined?(:ASSET_STORAGE)
    ATTACHED_FILE_OPTIONS[:storage] = ASSET_STORAGE

    if ASSET_STORAGE == :s3
      ATTACHED_FILE_OPTIONS[:s3_credentials] = "#{RAILS_ROOT}/config/s3.yml"
      ATTACHED_FILE_OPTIONS[:path] = ':attachment/:id/:style/:basename.:extension'
      ATTACHED_FILE_OPTIONS[:bucket] = ASSET_S3_BUCKET
    end
  end
  has_attached_file :data, ATTACHED_FILE_OPTIONS

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

  def editable?
    content_type = data_content_type || ''

    return true if content_type.match(/^text\//)
    return true if content_type.match(/javascript$/)
    return true if content_type.match(/xhtml/)

    false
  end

  private

  def set_default_handle
    self.handle = data_file_name if self.handle.blank?
  end
end
