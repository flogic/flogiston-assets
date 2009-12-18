require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe Admin::AssetsController do
  describe 'index' do
    before :each do
      @assets = Array.new(3) { |i|  Asset.generate! }
    end
    
    def do_get
      get :index
    end
    
    it 'should be successful' do
      do_get
      response.should be_success
    end
    
    it 'should make the assets available to the view' do
      do_get
      assigns[:assets].should == @assets
    end
    
    it 'should make an empty array available to the view if there are no assets' do
      Asset.delete_all
      do_get
      assigns[:assets].should == []
    end
    
    it 'should render the index template' do
      do_get
      response.should render_template('admin/assets/index')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
  end
  
  describe 'new' do
    def do_get
      get :new
    end
    
    it 'should be successful' do
      do_get
      response.should be_success
    end
    
    it 'should make a new asset available to the view' do
      do_get
      assigns[:asset].should be_instance_of(Asset)
      assigns[:asset].should be_new_record
    end
    
    it 'should render the new template' do
      do_get
      response.should render_template('admin/assets/new')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
  end
  
  describe 'create' do
    before :each do
      @asset = Asset.spawn
    end
    
    def do_post
      post :create, :asset => { :data_file_name => 'some_file.txt'}
    end
    
    it 'should create a new asset' do
      lambda { do_post }.should change(Asset, :count).by(1)
    end
    
    it 'should use the provided attributes when creating the asset' do
      Asset.delete_all
      do_post
      Asset.first.data_file_name.should == 'some_file.txt'
    end
    
    it 'should redirect to the admin list view' do
      Asset.delete_all
      do_post
      response.should redirect_to(admin_assets_path)
    end
    
    describe 'when saving is unsuccessful' do
      before :each do
        @asset.data_file_name = 'some_other_file.txt'
        Asset.any_instance.stubs(:save).returns(false)
      end
      
      def do_post
        post :create, :asset => @asset.attributes
      end
      
      it 'should be successful' do
        do_post
        response.should be_success
      end
      
      it 'should make a new asset available to the view' do
        do_post
        assigns[:asset].should be_new_record
      end
      
      it 'should initialize the asset with the given attributes' do
        do_post
        assigns[:asset].data_file_name.should == @asset.data_file_name
      end
      
      it 'should render the new template' do
        do_post
        response.should render_template('admin/assets/new')
      end
      
      it 'should use the admin layout' do
        do_post
        response.layout.should == 'layouts/admin'
      end
    end
  end
  
  describe 'edit' do
    before :each do
      @asset = Asset.generate!
      @asset_id = @asset.id.to_s
    end
    
    def do_get
      get :edit, :id => @asset_id
    end
    
    it 'should find the requested asset' do
      Asset.expects(:find).with(@asset_id).returns(@asset)
      do_get
    end
    
    it 'should make the found asset' do
      do_get
      assigns[:asset].should == @asset
    end
    
    it 'should render the edit template' do
      do_get
      response.should render_template('admin/assets/edit')
    end
    
    it 'should use the admin layout' do
      do_get
      response.layout.should == 'layouts/admin'
    end
  end
  
  describe 'update' do
    before :each do
      @asset = Asset.generate!
      @asset_id = @asset.id.to_s
    end
    
    def do_put
      put :update, :id => @asset_id, :asset => { :data_file_name => 'boring_file.txt' }
    end
    
    it 'should find the requested asset' do
      Asset.expects(:find).with(@asset_id).returns(@asset)
      do_put
    end
    
    it 'should use the provided attributes when updating the asset' do
      do_put
      @asset.reload
      @asset.data_file_name.should == 'boring_file.txt'
    end
    
    it 'should redirect to the admin list view' do
      do_put
      response.should redirect_to(admin_assets_path)
    end
    
    describe 'when saving is unsuccessful' do
      before :each do
        @asset.stubs(:save).returns(false)
        Asset.stubs(:find).with(@asset_id).returns(@asset)
        @new_name = 'other_boring_file.txt'
      end
      
      def do_put
        put :update, :id => @asset_id, :asset => @asset.attributes.merge('data_file_name' => @new_name)
      end
      
      it 'should be successful' do
        do_put
        response.should be_success
      end
      
      it 'should make the requested asset available to the view' do
        do_put
        assigns[:asset].id.should == @asset.id
      end
      
      it 'should set the asset attributes' do
        do_put
        assigns[:asset].data_file_name.should == @new_name
      end
      
      it 'should render the edit template' do
        do_put
        response.should render_template('admin/assets/edit')
      end
      
      it 'should use the admin layout' do
        do_put
        response.layout.should == 'layouts/admin'
      end
    end
  end
  
  describe 'destroy' do
    before :each do
      @asset = Asset.generate!
      @asset_id = @asset.id.to_s
    end

    def do_delete
      delete :destroy, :id => @asset_id
    end

    it 'should destroy the specified asset' do
      do_delete
      Asset.find_by_id(@asset_id).should be_nil
    end

    it 'should redirect to the admin assets list' do
      do_delete
      response.should redirect_to(admin_assets_path)
    end
  end
end
