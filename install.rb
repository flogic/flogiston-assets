require 'fileutils'

def plugin_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), relative))
end

def rails_path(relative)
  File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', relative))
end

def readme_contents
  IO.read(plugin_path('README.markdown'))
end

Dir[File.join(plugin_path('db/migrate'), '*.rb')].each do |migration|
  puts "Installing plugin migration #{migration} to #{rails_path('db/migrate')}..."
  FileUtils.copy(migration, rails_path('db/migrate'))
end

# run our Rails template to ensure needed gems and plugins are installed
system("rake rails:template LOCATION=#{plugin_path('templates/plugin-install.rb')}")

# and output our README
puts readme_contents
