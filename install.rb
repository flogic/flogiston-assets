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

puts "Installing plugin migrations"
FileUtils.cp_r(plugin_path('db/migrate'), rails_path('db'))

# run our Rails template to ensure needed gems and plugins are installed
system("rake rails:template LOCATION=#{plugin_path('templates/plugin-install.rb')}")

# and output our README
puts readme_contents
