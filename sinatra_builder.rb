require "fileutils"

class ProjectBuilder

  attr_accessor :project_name
  attr_accessor :project_path
  attr_accessor :lib_path
  attr_accessor :spec_path
  attr_accessor :views_path
  attr_accessor :css_path
  attr_accessor :img_path
  attr_accessor :js_path

  def initialize(project)
    self.project_name = project
    self.project_path = File.expand_path(File.join("~", "Desktop", project_name))
    self.lib_path = File.join(project_path, "lib")
    self.spec_path = File.join(project_path, "spec")
    self.views_path = File.join(project_path, "views")
    self.css_path = File.join(project_path, "public/css")
    self.img_path = File.join(project_path, "public/img")
    self.js_path = File.join(project_path, "public/js")
  end

  def build_folders
    [lib_path, spec_path, views_path, css_path, img_path, js_path].each do |folder|
      FileUtils.mkdir_p(folder)
    end
  end
  
  def write_contents(path, filename, contents = "")
    File.open(File.join(path, filename), "w") do |f|
      f.write(contents)
    end
  end

  def build_files
    write_contents project_path, "app.rb", <<-TEXT
require 'sinatra'
require 'sinatra/reloader'
require './lib/#{project_name}'
require 'pry'

also_reload('lib/**/*.rb')

get('/') do
  erb(:index)
end
TEXT

    write_contents project_path, "config.ru"

    write_contents project_path, "Gemfile", <<-TEXT
source "https://rubygems.org"
# ruby "2.4.1"

gem "sinatra"
gem "sinatra-contrib"
gem "rspec"
gem "capybara"
gem "pry"
TEXT

    write_contents project_path, "README.md"

    write_contents lib_path, "#{project_name}.rb"

    write_contents spec_path, "#{project_name}_spec.rb"

    write_contents spec_path, "#{project_name}_integration_spec.rb"

    write_contents views_path, "index.erb"

    write_contents views_path, "layout.erb"

    write_contents views_path, "output.erb"

    write_contents css_path, "styles.css"

    write_contents js_path, "scripts.js"

  end
  
end

puts "What is the name of your project?"

project_name = $stdin.gets.chomp
project_name.gsub!(/\s/, "_")
project_name.gsub!(/\W/, "")
project_name = "project" if project_name == ""

new_project = ProjectBuilder.new(project_name)

new_project.build_folders
new_project.build_files

puts "Building #{project_name}........"

`BUNDLE_GEMFILE=#{new_project.project_path}/Gemfile bundle install`

puts "#{new_project.project_name} built at:"
puts new_project.project_path