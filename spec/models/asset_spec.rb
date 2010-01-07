require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Asset do
  before :each do
    @asset = Asset.new
  end
  
  describe 'attributes' do
    it 'should have a handle' do
      @asset.should respond_to(:handle)
    end
    
    it 'should have data' do
      @asset.should respond_to(:data)
    end
    
    describe 'supporting data attachment' do
      it 'should have a data file name' do
        @asset.should respond_to(:data_file_name)
      end
    
      it 'should have a data content type' do
        @asset.should respond_to(:data_content_type)
      end
    
      it 'should have a data file size' do
        @asset.should respond_to(:data_file_size)
      end
    end
  end
  
  describe 'validations' do
    it 'should not error on handle if given' do
      Asset.delete_all
      @asset = Asset.new(:handle => 'test_handle')
      @asset.valid?
      @asset.errors.should_not be_invalid(:handle)
    end
    
    it 'should error on handle if not unique' do
      handle = 'test_handle'
      Asset.delete_all
      other_asset = Asset.create!(:handle => handle)
      @asset = Asset.new(:handle => handle)
      @asset.valid?
      @asset.errors.should be_invalid(:handle)
    end
    
    it 'should not error on handle if none given' do
      @asset = Asset.new(:handle => nil)
      @asset.valid?
      @asset.errors.should_not be_invalid(:handle)
    end
  end
end
