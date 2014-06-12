
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
  database: #{@app_name}_dev

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: #{@app_name}_test

production:
  <<: *default
  database: #{@app_name}_prod

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