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
  end
end
