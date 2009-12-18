require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe 'admin/assets/index.html.haml' do
  before :each do
    @asset = Asset.generate!
    assigns[:assets] = [@asset]
  end
  
  def do_render
    render 'admin/assets/index.html.haml'
  end
  
  it 'should have an assets list' do
    do_render
    response.should have_tag('table[id=?]', 'assets')
  end
  
  describe 'assets list' do
    it 'should have a row for the asset' do
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr')
        end
      end
    end
    
    it 'should include the asset file name' do
      @asset.data_file_name = 'some_file.txt'
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr', :text => Regexp.new(Regexp.escape(@asset.data_file_name)))
        end
      end
    end
    
    it 'should include the asset file type' do
      @asset.data_content_type = 'text/plain'
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr', :text => Regexp.new(Regexp.escape(@asset.data_content_type)))
        end
      end
    end
    
    it 'should include the asset file size' do
      @asset.data_file_size = 123940
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr', :text => Regexp.new(Regexp.escape(@asset.data_file_size.to_s)))
        end
      end
    end
    
    it 'should link to edit the asset' do
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?]', edit_admin_asset_path(@asset))
          end
        end
      end
    end
    
    it 'should link to destroy the asset' do
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          with_tag('tr') do
            with_tag('a[href=?][onclick*=?]', admin_asset_path(@asset), 'delete')
          end
        end
      end
    end
    
    it 'should have a list item for every asset' do
      other_asset = Asset.generate!
      assigns[:assets] = [@asset, other_asset]
      
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          [@asset, other_asset].each do |asset|
            with_tag('tr') do
              with_tag('a[href=?]', edit_admin_asset_path(asset))
            end
          end
        end
      end
    end
    
    it 'should have no list items if there are no assets' do
      assigns[:assets] = []
      do_render
      response.should have_tag('table[id=?]', 'assets') do
        with_tag('tbody') do
          without_tag('tr')
        end
      end
    end
  end
end
