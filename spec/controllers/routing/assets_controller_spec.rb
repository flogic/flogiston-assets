require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe AssetsController do
  describe 'mapping routes' do
    it "should map { :controller => 'assets', :action => 'show', :id => '1' } to /assets/1" do
      route_for(:controller => 'assets', :action => 'show', :id => '1').should == '/assets/1'
    end
  end
  
  describe 'generating params' do
    it "should generate params { :controller => 'assets', action => 'show', :id => '1' } from GET /assets/1" do
      params_from(:get, '/assets/1').should == { :controller => 'assets', :action => 'show', :id => '1' }
    end
  end
end
