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
  attr_accessor :config_path

  def initialize(project)
    self.project_name = project
    self.project_path = File.expand_path(File.join("~", "Desktop", project_name))
    self.lib_path = File.join(project_path, "lib")
    self.spec_path = File.join(project_path, "spec")
    self.views_path = File.join(project_path, "views")
    self.css_path = File.join(project_path, "public/css")
    self.img_path = File.join(project_path, "public/img")
    self.js_path = File.join(project_path, "public/js")
    self.config_path = File.join(project_path, "config")
  end

  def build_folders
    [lib_path, spec_path, views_path, css_path, img_path, js_path, config_path].each do |folder|
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
require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "./lib/#{project_name}"
require "pry"

also_reload "lib/**/*.rb"

get "/" do
  erb :index
end
TEXT

    write_contents project_path, "config.ru", <<-TEXT
require "./app"
run Sinatra::Application
TEXT

    write_contents project_path, "Gemfile", <<-TEXT
source "https://rubygems.org"
# ruby "2.4.1"

gem "sinatra-contrib", require: "sinatra/reloader"
gem "sinatra-activerecord"
gem "pg"
gem "rake"
gem "pg"
gem "sinatra"

group :test do
  gem "rspec"
  gem "capybara"
  gem "pry"
end
TEXT

    write_contents project_path, "Rakefile", <<-TEXT
require "sinatra/activerecord"
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config
end
TEXT

    write_contents project_path, "README.md", <<-TEXT
# <!--PROJECT NAME HERE-->

<!--PROJECT DESCRIPTION HERE-->

### Prerequisites

Web browser with ES6 compatibility
Examples: Chrome, Safari

Ruby <!--VERSION HERE-->
Bundler

### Installing

Installation is quick and easy! First you can open this link <!--HEROKU LINK HERE--> to see the webpage in action live online. Or you can clone this repository to your machine, navigate to the file path in your terminal, and run 'app.rb' by typing '$ruby app.rb'. If you chose to clone the repository, after you run 'app.rb' you will need to copy the localhost path into your web browser. The standard localhost for Sinatra is port 4567

## Built With

* Ruby
* Sinatra
* HTML
* CSS
* Bootstrap https://getbootstrap.com/
* ES6
* Jquery https://jquery.com/

## Authors

* <!--YOUR NAME HERE-->

## License

MIT License

Copyright (c) <!--YOUR NAME & YEAR HERE-->

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

TEXT

    write_contents spec_path, "#{project_name}_spec.rb", <<-TEXT
require "spec_helper"

# describe 'Palindrome#isWord?' do
#   let(:word) { Palindrome.new }

#   it "returns true if the word has at least one vowel" do
#     expect(word.is_word?("word")).to eq true
#   end

#   it "returns false if the word does not have a vowel" do
#     expect(word.is_word?("wrd")).to eq false
#   end

# end
TEXT

    write_contents spec_path, "#{project_name}_integration_spec.rb", <<-TEXT
require "capybara/rspec"
require "spec_helper"
require "./app"

Capybara.app = Sinatra::Application
set(:show_exceptions, false)

# describe("the phrase parser path", {:type => :feature}) do
#   it("processes the user input and returns correct message if its a palindrome") do
#     visit("/")
#     fill_in("phrase1", :with => "madam")
#     fill_in("phrase2", :with => "anagram")
#     click_button("what am i?")
#     expect(page).to have_content("'madam' is a palindrome")
#   end
# end
TEXT

  write_contents spec_path, "spec_helper.rb", <<-TEXT
ENV["RACK_ENV"] = "test"

require "rspec"
require "pg"
require "pry"
require "sinatra/activerecord"
require "#{project_name}"

# RSpec.configure do |config|
#   config.after(:each) do
#     Department.all.each do |d|
#       d.destroy
#     end
#   end
# end
TEXT

    write_contents views_path, "layout.erb", <<-TEXT
<!DOCTYPE html>
<html>
  <head>
    <title></title>
    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>
    <link  rel='stylesheet' href="/css/styles.css" >
    <script src="https://code.jquery.com/jquery-3.2.1.js" integrity="sha256-DZAnKJ/6XZ9si04Hgrsxu/8s717jcIzLy3oi35EouyE=" crossorigin="anonymous"></script>
    <script src="js/scripts.js"></script>
  </head>
  <body>
    <div class="container">
    <h1></h1>
    <hr>
      <%= yield %>
    </div>
  </body>
</html>
TEXT

    write_contents css_path, "styles.css"

    write_contents js_path, "scripts.js"

    write_contents views_path, "index.erb"

    write_contents lib_path, "#{project_name}.rb"

    write_contents config_path, "database.yml", <<-TEXT
development:
  adapter: postgresql
  database: #{project_name}_development
test:
  adapter: postgresql
  database: #{project_name}_test
TEXT

  end

end

puts "What is the name of your project?"

project_name = $stdin.gets.chomp
project_name.gsub!(/\s/, "_")
project_name.gsub!(/\W/, "")
project_name = "project" if project_name == ""

puts "Building #{project_name}........"

new_project = ProjectBuilder.new(project_name)

new_project.build_folders
new_project.build_files

puts "Running bundler........"

`BUNDLE_GEMFILE=#{new_project.project_path}/Gemfile bundle install`

puts "#{new_project.project_name} built at:"
puts new_project.project_path
