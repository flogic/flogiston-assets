require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Asset do
  def reset_model
    Object.send(:remove_const, :Asset)
    Flogiston.send(:remove_const, :Asset)
    load "#{RAILS_ROOT}/vendor/plugins/flogiston-assets/app/models/flogiston/asset.rb"
    load "#{RAILS_ROOT}/app/models/asset.rb"
  end

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

  describe 'data options' do
    describe 'when config options are set for s3' do
      before do
        [:ASSET_STORAGE, :ASSET_S3_BUCKET].each do |const|
          Object.send(:remove_const, const) if Object.const_defined?(const)
        end

        Object.const_set(:ASSET_STORAGE, :s3)
        Object.const_set(:ASSET_S3_BUCKET, 'flogiston-assets-test')

        reset_model
        @asset = Asset.new
      end

      after do
        [:ASSET_STORAGE, :ASSET_S3_BUCKET].each do |const|
          Object.send(:remove_const, const) if Object.const_defined?(const)
        end
      end

      it 'should use s3 storage' do
        @asset.data.options.storage.should == :s3
      end

      it 'should look for s3 credentials in config/s3.yml' do
        @asset.data.options.s3_credentials.should == "#{RAILS_ROOT}/config/s3.yml"
      end

      it 'should set the path' do
        @asset.data.options.path.should == ':attachment/:id/:style/:basename.:extension'
      end

      it 'should set the bucket from the associated constant' do
        @asset.data.options.bucket.should == 'flogiston-assets-test'
      end
    end

    describe 'when config options are not set' do
      before do
        Object.send(:remove_const, :ASSET_STORAGE) if Object.const_defined?(:ASSET_STORAGE)

        reset_model
        @asset = Asset.new
      end

      it 'should use filesystem storage' do
        @asset.data.options.storage.should == :filesystem
      end
    end
  end

  it 'should indicate whether s3 storage is used' do
    @asset.should respond_to(:s3?)
  end

  describe 'indicating whether s3 storage is used' do
    before do
      @options = stub('options')
      @data = stub('data', :options => @options)
      @asset.stubs(:data).returns(@data)
    end

    it 'should get the storage value from the data options' do
      @options.expects(:storage)
      @asset.s3?
    end

    it 'should return true if the storage value is :s3' do
      @options.stubs(:storage).returns(:s3)
      @asset.s3?.should == true
    end

    it 'should return false if the storage value is not :s3' do
      @options.stubs(:storage).returns(:something)
      @asset.s3?.should == false
    end
  end

  describe 'to support direct editing' do
    it "should have a 'contents' attribute" do
      @asset.should respond_to(:contents)
    end

    describe 'contents' do
      describe 'when using filesystem storage' do
        before do
          Object.send(:remove_const, :ASSET_STORAGE) if Object.const_defined?(:ASSET_STORAGE)
          reset_model
        end

        before do
          @asset = Asset.new
          @file_path = File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])
        end

        after do
          @asset.destroy
        end

        it 'should return the contents of the data file' do
          File.open(@file_path) { |file|  @asset.data = file }
          @asset.save!

          expected = nil
          File.open(@file_path) { |file|  expected = file.read }

          @asset.contents.should == expected
        end

        it 'should return nil for a new record' do
          File.open(@file_path) { |file|  @asset.data = file }

          @asset.contents.should == nil
        end

        it 'should return nil for non-file data'
      end

      describe 'when using s3 storage' do
        before do
          [:ASSET_STORAGE, :ASSET_S3_BUCKET].each do |const|
            Object.send(:remove_const, const) if Object.const_defined?(const)
          end

          Object.const_set(:ASSET_STORAGE, :s3)
          Object.const_set(:ASSET_S3_BUCKET, 'flogiston-assets-test')

          reset_model
        end

        after do
          [:ASSET_STORAGE, :ASSET_S3_BUCKET].each do |const|
            Object.send(:remove_const, const) if Object.const_defined?(const)
          end
        end

        before do
          @asset = Asset.new
          @file_path = File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])
        end

        after do
          @asset.destroy
        end

        it 'should return the contents of the data file' do
          File.open(@file_path) { |file|  @asset.data = file }
          @asset.save!

          expected = nil
          File.open(@file_path) { |file|  expected = file.read }

          @asset.contents.should == expected
        end

        it 'should return nil for a new record' do
          File.open(@file_path) { |file|  @asset.data = file }

          @asset.contents.should == nil
        end

        it 'should return nil for non-file data'
      end
    end

    it "should have a 'contents' setter method" do
      @asset.should respond_to(:contents=)
    end

    describe 'setting contents' do
      before do
        @test_file = File.join(File.dirname(__FILE__), %w[.. contents_setting_test_file])
        File.open(@test_file, 'w') do |file|
          3.times do
            file.puts 'blah blah blah'
            file.puts 'fa fa fa'
          end
        end

        @asset = Asset.create!(:data => File.open(@test_file))
      end

      after do
        File.unlink(@test_file)
      end

      it 'should change the asset contents to the given contents' do
        new_contents = "This is all-new stuff right here.
          Get excited!
          Are you excited?"
        expected = new_contents.dup

        @asset.update_attributes!(:contents => new_contents)
        @asset.contents.should == expected
      end

      it 'should update the stored file size' do
        new_contents = "Something borrowed. Something blue."
        expected = new_contents.length

        @asset.update_attributes!(:contents => new_contents)
        @asset.data_file_size.should == expected
      end

      it 'should not change the file name' do
        new_contents = "Thinking of something else."
        expected = @asset.data_file_name.dup

        @asset.update_attributes!(:contents => new_contents)
        @asset.data_file_name.should == expected
      end

      it 'should not change the content type' do
        new_contents = "Something else goes here."
        expected = @asset.data_content_type.dup

        @asset.update_attributes!(:contents => new_contents)
        @asset.data_content_type.should == expected
      end

      it 'should change the actual stored file' do
        new_contents = "I'm bored of coming up with new data."
        expected = new_contents.dup

        @asset.update_attributes!(:contents => new_contents)

        file_contents = nil
        File.open(@asset.data.path) { |file|  file_contents = file.read }
        file_contents.should == expected
      end

      # This is troublesome because it doesn't actually operate on the original file,
      # but instead where it has stored a copy of the file (see the test above to see
      # the stored file gets changed). Maybe what I should really be doing is testing
      # that @asset.data.path doesn't point to a file.
      it 'should do nothing for a new record' do
        @asset = Asset.new(:data => File.open(@test_file))
        new_contents = "Will this work?"

        expected = nil
        File.open(@test_file) { |file|  expected = file.read }

        @asset.contents = new_contents
        @asset.save!
        @asset.contents.should == expected
      end

      it 'should do nothing for non-file data'

      it 'should not override setting the data directly' do
        new_contents = "Something something something something something"

        new_test_file = @test_file + '_but_wait_theres_more'
        File.open(new_test_file, 'w') do |file|
          file.puts 'crip crap crup'
        end

        expected_name = File.basename(new_test_file)
        expected_contents = nil
        File.open(new_test_file) { |file|  expected_contents = file.read }
        expected_size = expected_contents.length
        expected_type = 'text/plain'

        @asset.update_attributes!(:contents => new_contents, :data => File.open(new_test_file))

        @asset.contents.should == expected_contents
        @asset.data_file_name.should == expected_name
        @asset.data_file_size.should == expected_size
        @asset.data_content_type.should == expected_type

        File.unlink(new_test_file)
      end
    end

    it 'should indicate whether the contents are editable' do
      @asset.should respond_to(:editable?)
    end

    describe 'indicating whether the contents are editable' do
      it 'should return true for plain text' do
        @asset.data_content_type = 'text/plain'
        @asset.should be_editable
      end

      it 'should return true for css' do
        @asset.data_content_type = 'text/css'
        @asset.should be_editable
      end

      it 'should return true for any sort of text content' do
        @asset.data_content_type = 'text/adsflkjasdf'
        @asset.should be_editable
      end

      it 'should return true for javascript' do
        @asset.data_content_type = 'application/x-javascript'
        @asset.should be_editable
      end

      it 'should return true for XHTML' do
        @asset.data_content_type = 'application/xhtml+xml'
        @asset.should be_editable
      end

      it 'should return false for PDF' do
        @asset.data_content_type = 'application/pdf'
        @asset.should_not be_editable
      end

      it 'should return false for PDF' do
        @asset.data_content_type = 'crazy/town'
        @asset.should_not be_editable
      end

      it 'should return false for unset content type' do
        @asset.data_content_type = nil
        @asset.should_not be_editable
      end
    end
  end
end
