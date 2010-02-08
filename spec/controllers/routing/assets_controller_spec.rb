require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe AssetsController do
  describe 'mapping routes' do
    # it's kind of annoying that ID *has* to be given as an array just because it *can*
    it "should map { :controller => 'assets', :action => 'show', :id => ['1'] } to /assets/1" do
      route_for(:controller => 'assets', :action => 'show', :id => ['1']).should == '/assets/1'
    end
  end
  
  describe 'generating params' do
    it "should generate params { :controller => 'assets', action => 'show', :id => ['1'] } from GET /assets/1" do
      params_from(:get, '/assets/1').should == { :controller => 'assets', :action => 'show', :id => ['1'] }
    end
    
    it "should generate params { :controller => 'assets', action => 'show', :id => ['some', 'path'] } from GET /assets/some/path" do
      params_from(:get, '/assets/some/path').should == { :controller => 'assets', :action => 'show', :id => ['some', 'path'] }
    end
    
    it "should generate params { :controller => 'assets', action => 'show', :id => ['some', 'path.ext'] } from GET /assets/some/path" do
      params_from(:get, '/assets/some/path.ext').should == { :controller => 'assets', :action => 'show', :id => ['some', 'path.ext'] }
    end
    
    it "should generate params { :controller => 'assets', action => 'show', :id => ['path.ext'] } from GET /assets/some/path" do
      params_from(:get, '/assets/path.ext').should == { :controller => 'assets', :action => 'show', :id => ['path.ext'] }
    end
  end
end
