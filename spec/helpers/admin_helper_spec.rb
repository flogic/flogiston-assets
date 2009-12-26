require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe AdminHelper do
  describe 'admin sections' do
    it 'should include assets' do
      helper.admin_sections.should include('assets')
    end
  end
end
