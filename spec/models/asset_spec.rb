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
  
  describe 'when created' do
    it 'should default the handle to the filename if none given' do
      @asset = Asset.new
      File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  @asset.data = file }
      @asset.save!
      
      @asset.reload
      
      @asset.handle.should == 'spec_helper.rb'
    end
    
    it 'should default the handle to the filename if a blank handle given' do
      @asset = Asset.new(:handle => '')
      File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  @asset.data = file }
      @asset.save!
    
      @asset.reload
    
      @asset.handle.should == 'spec_helper.rb'
    end
    
    it 'should not override a supplied handle with a filename-derived default' do
      handle = 'some_asset'
      @asset = Asset.new(:handle => handle)
      File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  @asset.data = file }
      @asset.save!
    
      @asset.reload
    
      @asset.handle.should == handle
    end
  end

  describe 'to support direct editing' do
    it "should have a 'contents' attribute" do
      @asset.should respond_to(:contents)
    end

    describe 'contents' do
      it 'should return the contents of the data file' do
        @asset = Asset.new
        File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  @asset.data = file }
        @asset.save!

        expected = nil
        File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  expected = file.read }

        @asset.contents.should == expected
      end

      it 'should return nil for a new record' do
        @asset = Asset.new
        File.open(File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])) { |file|  @asset.data = file }

        @asset.contents.should == nil
      end

      it 'should return nil for non-file data'
    end
  end

end
