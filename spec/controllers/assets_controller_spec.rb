require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe AssetsController do
  describe 'show' do
    before :each do
      @asset = Asset.generate!
      @asset_id = @asset.id.to_s
      
      @data = stub('data', :path => 'path/to/file', :content_type => 'content/type')
      @asset.stubs(:data).returns(@data)
      @asset.stubs(:s3?).returns(false)

      Asset.stubs(:find).returns(@asset)
      Asset.stubs(:find_by_handle).returns(nil)
      controller.stubs(:send_file)
    end
    
    describe 'using a simple numeric ID' do
      def do_get
        get :show, :id => [@asset_id]  # still comes in as an array thanks to the route
      end
    
      it 'should find the requested asset by handle' do
        Asset.expects(:find_by_handle).with(@asset_id).returns(@asset)
        do_get
      end
    
      it 'should find the requested asset by ID after the handle search is unsuccessful' do
        Asset.stubs(:find_by_handle).returns(nil)
        Asset.expects(:find).with(@asset_id).returns(@asset)
        do_get
      end

      describe 'when the asset is not stored on s3' do
        before do
          @asset.stubs(:s3?).returns(false)
        end

        it 'should render the asset' do
          controller.expects(:send_file).with(@data.path, :type => @data.content_type, :disposition => 'inline')
          do_get
        end

        it 'should not redirect' do
          do_get
          response.should be_success
        end
      end

      describe 'when the asset is stored on s3' do
        before do
          @asset.stubs(:s3?).returns(true)

          @s3_url = 'http://s3.amazonaws.com/some/bucket/stuff/goes/here'
          @data.stubs(:url).returns(@s3_url)
        end

        it 'should redirect to the s3 URL' do
          do_get
          response.should redirect_to(@s3_url)
        end

        it 'should not try to render the asset' do
          controller.expects(:send_file).never
          do_get
        end
      end
    end
    
    describe 'using a path-like handle' do
      before :each do
        @handle = 'some/path/here.ext'
        @parts  = @handle.split('/')
      end
      
      def do_get
        get :show, :id => @parts
      end
    
      it 'should find the requested asset by handle' do
        Asset.expects(:find_by_handle).with(@handle).returns(@asset)
        do_get
      end
    
      it 'should find the requested asset by ID after the handle search is unsuccessful' do
        Asset.stubs(:find_by_handle).returns(nil)
        Asset.expects(:find).with(@handle).returns(@asset)
        do_get
      end

      describe 'when the asset is not stored on s3' do
        before do
          @asset.stubs(:s3?).returns(false)
        end

        it 'should render the asset' do
          controller.expects(:send_file).with(@data.path, :type => @data.content_type, :disposition => 'inline')
          do_get
        end

        it 'should not redirect' do
          do_get
          response.should be_success
        end
      end

      describe 'when the asset is stored on s3' do
        before do
          @asset.stubs(:s3?).returns(true)

          @s3_url = 'http://s3.amazonaws.com/some/bucket/stuff/goes/here'
          @data.stubs(:url).returns(@s3_url)
        end

        it 'should redirect to the s3 URL' do
          do_get
          response.should redirect_to(@s3_url)
        end

        it 'should not try to render the asset' do
          controller.expects(:send_file).never
          do_get
        end
      end
    end
  end
end
