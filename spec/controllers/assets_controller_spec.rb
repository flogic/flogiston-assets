require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe AssetsController do
  describe 'show' do
    before :each do
      @asset = Asset.generate!
      @asset_id = @asset.id.to_s
      
      @data = stub('data', :path => 'path/to/file', :content_type => 'content/type')
      @asset.stubs(:data).returns(@data)
      Asset.stubs(:find).returns(@asset)
      controller.stubs(:send_file)
    end
    
    def do_get
      get :show, :id => @asset_id
    end
    
    it 'should find the requested asset' do
      Asset.expects(:find).with(@asset_id).returns(@asset)
      do_get
    end
    
    it 'should render the asset' do
      controller.expects(:send_file).with(@data.path, :type => @data.content_type, :disposition => 'inline')
      do_get
    end
  end
end