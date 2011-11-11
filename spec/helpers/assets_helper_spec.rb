require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe AssetsHelper do
  it 'should provide an asset_link method' do
    helper.should respond_to(:asset_link)
  end

  describe 'asset_link' do
    before do
      @handle = 'some_handle'
    end

    it 'should accept a handle' do
      lambda { helper.asset_link(@handle) }.should_not raise_error(ArgumentError)
    end

    it 'should require a handle' do
      lambda { helper.asset_link }.should raise_error(ArgumentError)
    end

    it 'should find the requested Asset' do
      Asset.expects(:find_by_handle).with(@handle)
      helper.asset_link(@handle)
    end

    it 'should return the data URL if the Asset uses s3 storage' do
      url = 'http://s3.amazonaws.com/bucket/path/stuff'

      asset = Asset.generate!
      asset.stubs(:s3?).returns(true)
      asset.data.stubs(:url).returns(url)

      Asset.stubs(:find_by_handle).returns(asset)

      helper.asset_link(@handle).should == url
    end

    it 'should return the local controller path if the Asset does not use s3 storage' do
      asset = Asset.generate!
      asset.stubs(:s3?).returns(false)
      Asset.stubs(:find_by_handle).returns(asset)

      helper.asset_link(@handle).should == "/assets/#{@handle}"
    end

    it 'should return the empty string if no matching Asset exists' do
      Asset.stubs(:find_by_handle).returns(nil)
      helper.asset_link(@handle).should == ''
    end
  end
end
