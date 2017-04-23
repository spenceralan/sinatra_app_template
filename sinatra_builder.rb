require "fileutils"

puts "What is the name of your project?"

project = $stdin.gets.chomp
project.gsub!(/\s/, "_")
project = "project" if project == ""


puts "Building #{project}........"

project_path = File.expand_path(File.join("~", "Desktop", project))
lib_path = File.join(project_path, "lib")
spec_path = File.join(project_path, "spec")
views_path = File.join(project_path, "views")
css_path = File.join(project_path, "public/css")
img_path = File.join(project_path, "public/img")
js_path = File.join(project_path, "public/js")

[lib_path, spec_path, views_path, css_path, img_path, js_path].each do |folder|
  FileUtils.mkdir_p(folder)
end

def write_file(path, filename, contents)
  File.open(File.join(path, filename), "w") do |f|
    f.write(contents)
  end
end

write_file project_path, "app.rb", <<-TEXT
require 'sinatra'
require 'sinatra/reloader'
require './lib/#{project}'
require 'pry'

also_reload('lib/**/*.rb')

get('/') do
  erb(:index)
end
TEXT

