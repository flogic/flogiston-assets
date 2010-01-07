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
end
