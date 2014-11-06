
#remove comments / excess whitespace / unused gems from gemfile
gsub_file("Gemfile", /# .*[\r\n]?/, "")           #remove comments
gsub_file("Gemfile", /\n{2,}/, "\n")              #remove excess whitespace
gsub_file "Gemfile", /gem 'sqlite3'[\r\n]/, ""    # remove sqlite
gsub_file "Gemfile", /gem 'turbolinks'[\r\n]/, "" # remove turbolinks

# remove other code related to turbolinks
gsub_file "app/views/layouts/application.html.erb", /, ('|")data-turbolinks-track('|") => true/, ""
gsub_file "app/assets/javascripts/application.js", /\/\/= require turbolinks[\r\n]/, ""


#add ruby version
insert_into_file "Gemfile", "ruby '2.1.2'\n", after: "source 'https://rubygems.org'\n"

# add new gems.
gem 'pg'

# add rspec / other test stuff
gem_group :development, :test do
  gem 'awesome_print'
  gem 'rspec-rails'
end

run "bundle install"
generate "rspec:install"
remove_dir "test"

#update .gitignore
append_file ".gitignore" do
<<END

/config/database.yml
.DS_Store
.idea
END
end

database_name = @app_name.gsub('-','_')

# create a new database.yml that works with PG.
create_file "config/database.sample.yml" do
<<END
default: &default
  adapter: postgresql
  encoding: utf8
  host: localhost
  username: username
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: #{database_name}_dev

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: #{database_name}_test

production:
  <<: *default
  database: #{database_name}_prod

END
end

remove_file "config/database.yml"
run "cp config/database.sample.yml config/database.yml"

# create new README file
remove_file "README.rdoc"
create_file "README.md" do
<<END
# #{@app_name}
END
end


=begin

heroku commands:

====== creating a new heroku app:
mkdir example
cd example
git init
heroku apps:create


heroku apps:create
===== set up heroku remotes from git
https://devcenter.heroku.com/articles/multiple-environments
heroku create --remote staging
heroku create --remote production


-------------

#have to do git init first.
git init. then do intial checkin.

heroku apps:create bottega8-<app name> -remote production
heroku apps:create bottega8-<app name>-staging -remote staging


-------------

#### WHY SHOULD YOU DEPLOY TO HEROKU EARLY AND OFTEN??
because if you can run into production problems and its harder to figure out what is causing the issue when
you've made a ton of changes.
https://devcenter.heroku.com/articles/getting-started-with-rails4

# use the 12factor gem for heroku
gem 'rails_12factor', group: :production

-------------

### app environment variables
app_environment_variables.rb
(add variables here)
then add to git ignore.
also probably create an example file for this like the database.yml file.

add these lines to config/environment.rb (like edunami)
# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)


-----------
Setting up poltergist
https://github.com/teampoltergeist/poltergeist

in the rails-setup/ rspec setup file
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

=end