require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe 'admin/assets/edit.html.haml' do
  before :each do
    assigns[:asset] = @asset = Asset.generate!
  end
  
  def do_render
    render 'admin/assets/edit.html.haml'
  end
  
  it 'should have an edit-asset form' do
    do_render
    response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}")
  end
  
  describe 'new-asset form' do
    it 'should use the asset update action' do
      do_render
      response.should have_tag('form[id=?][action=?][method=?]', "edit_asset_#{@asset.id}", admin_asset_path(@asset), 'post') do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end
    
    it 'should be multipart' do
      do_render
      response.should have_tag('form[id=?][enctype=?]', "edit_asset_#{@asset.id}", 'multipart/form-data')
    end
    
    it 'should have a data file input' do
      do_render
      response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
        with_tag('input[type=?][name=?]', 'file', 'asset[data]')
      end
    end
    
    it 'should have a handle input' do
      do_render
      response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
        with_tag('input[type=?][name=?]', 'text', 'asset[handle]')
      end
    end
    
    it 'should populate the handle input' do
      @asset.handle = 'some_handle'
      do_render
      response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
        with_tag('input[type=?][name=?][value=?]', 'text', 'asset[handle]', @asset.handle)
      end
    end

    describe 'when the content is editable' do
      before do
        @asset.stubs(:editable?).returns(true)
      end

      it 'should have a contents input' do
        do_render
        response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
          with_tag('textarea[name=?]', 'asset[contents]')
        end
      end

      it 'should populate the contents input' do
        contents = 'blah de blah blah blah'
        @asset.stubs(:contents).returns(contents)
        do_render
        response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
          with_tag('textarea[name=?]', 'asset[contents]', contents)
        end
      end
    end

    describe 'when the content is not editable' do
      before do
        @asset.stubs(:editable?).returns(false)
      end

      it 'should not have a contents input' do
        do_render
        response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
          without_tag('textarea[name=?]', 'asset[contents]')
        end
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', "edit_asset_#{@asset.id}") do
        with_tag('input[type=?]', 'submit')
      end
    end
  end
  
  describe 'when errors are available' do
    it 'should display errors in an error region' do
      @asset.errors.add_to_base("error on this page")
      do_render
      response.should have_tag('div[class=?]', 'errors', :text => /error on this page/)
    end
  end
  
  describe 'when no errors are available' do
    it 'should not display errors' do
      do_render
      response.should_not have_tag('div[class=?]', 'errors')
    end
  end
end
