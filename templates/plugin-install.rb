plugin 'flogiston', :git => 'git://github.com/flogic/flogiston.git'

plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git'

Dir["#{RAILS_ROOT}/vendor/plugins/flogiston-assets/app/models/flogiston/*.rb"].each do |f|
  filename = File.basename(f, '.rb')
  model_name = filename.camelize

  if File.exist?("app/models/#{filename}.rb")
    puts "*** model #{filename}.rb exists. Ensure it defines #{model_name} < Flogiston::#{model_name}. ***"
  else
    file "app/models/#{filename}.rb", <<-eof
class #{model_name} < Flogiston::#{model_name}
end
    eof
  end
end
