require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe 'admin/assets/new.html.haml' do
  before :each do
    assigns[:asset] = @asset = Asset.new
  end
  
  def do_render
    render 'admin/assets/new.html.haml'
  end
  
  it 'should have a new-asset form' do
    do_render
    response.should have_tag('form[id=?]', 'new_asset')
  end
  
  describe 'new-asset form' do
    it 'should use the asset create action' do
      do_render
      response.should have_tag('form[id=?][action=?][method=?]', 'new_asset', admin_assets_path, 'post')
    end
    
    it 'should be multipart' do
      do_render
      response.should have_tag('form[id=?][enctype=?]', 'new_asset', 'multipart/form-data')
    end
    
    it 'should have a data file input' do
      do_render
      response.should have_tag('form[id=?]', 'new_asset') do
        with_tag('input[type=?][name=?]', 'file', 'asset[data]')
      end
    end

    it 'should have a submit button' do
      do_render
      response.should have_tag('form[id=?]', 'new_asset') do
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
