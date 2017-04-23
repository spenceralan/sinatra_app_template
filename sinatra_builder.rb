require "fileutils"

puts "What is the name of your project?"

project = $stdin.gets.chomp
project.gsub!(/\s/, "_")
project = "project" if project == ""


puts "Building #{project}........"

PROJECT_PATH = File.expand_path(File.join("~", "Desktop", project))

["lib", "spec", "views", "public/css", "public/img", "public/js"].each do |filename|
  FileUtils.mkdir_p(File.join(PROJECT_PATH, filename))
end

