module Maguro

  class Features
    attr_reader :project, :gemfile, :app_name

    def initialize(new_project)
      @project = new_project
      @app_name = @project.send(:app_name)
      @gemfile = Maguro::Gemfile.new(new_project)
    end

    def clean_gemfile
      gemfile.remove(/# .*[\r\n]?/, "")           #remove comments
      gemfile.remove(/\n{2,}/, "\n")              #remove excess whitespace
    end

    def remove_turbo_links
      # remove turbolinks
      project.gsub_file "Gemfile", /gem 'turbolinks'[\r\n]/, ""

      # remove other code related to turbolinks
      project.gsub_file "app/views/layouts/application.html.erb", /, ('|")data-turbolinks-track('|") => true/, ""
      project.gsub_file "app/assets/javascripts/application.js", /\/\/= require turbolinks[\r\n]/, ""
    end

    def add_ruby_version
      #add ruby version
      project.insert_into_file "Gemfile", "ruby '#{Maguro::RUBY_VERSION}'\n", after: "source 'https://rubygems.org'\n"
    end

    def use_pg
      project.gsub_file "Gemfile", /gem 'sqlite3'[\r\n]/, ""    # remove sqlite
      project.gem 'pg'          # add new gems.
    end

    def add_test_gems
      project.gem_group :development, :test do
        gem 'awesome_print'
        gem 'rspec-rails'
      end
    end

    def install_rspec
      project.run "bundle install"
      project.generate "rspec:install"
      project.remove_dir "test"
    end


    # Update gitignore file with common stuff that we use.
    def update_gitignore
      project.append_file ".gitignore" do
        <<-END.strip_heredoc

        /config/database.yml
        .DS_Store
        .idea
        END
      end
    end

    # create a new database.yml that works with PG.
    def create_database_sample

      database_name = app_name.gsub('-','_')

      project.create_file "config/database.sample.yml" do
        <<-END.strip_heredoc
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

      project.remove_file "config/database.yml"
      project.run "cp config/database.sample.yml config/database.yml"
    end


    #create a README.md file
    def create_readme
      project.remove_file "README.rdoc"
      project.create_file "README.md" do
        <<-END.strip_heredoc
# #{app_name}

## Setup

### Requirements

1. [ruby](https://www.ruby-lang.org/en/)
2. [postgres](http://www.postgresql.org/download/) (can be installed via homebrew)


### Recommended (If using a mac these are required / HIGHLY recommended)

1. [rvm](https://rvm.io/)
2. [homebrew](http://brew.sh/)

### Initialization Steps

0. Make sure your computer is set up for Ruby on Rails development and you have pulled the code

1. Make your own copy of database.yml `cp ./config/database.sample.yml ./config/database.yml`
2. Configure your database.yml. If you have a default setup you shouldn't have to do anything.
3. Make your own copy of app_environment_variables.rb `cp config/app_environment_variables.sample.rb config/app_environment_variables.rb`
4. Install PostgreSQL `brew install postgresql`
5. Make sure postgresql is running
6. Use Rails #{Maguro::RUBY_VERSION} `rvm use #{Maguro::RUBY_VERSION}`
7. `bundle install`
8. `rake db:create db:migrate db:seed`
9. Run tests to make sure they pass `rspec spec/`
10. `rails s`

### Updates

Occasionally you will have to update your app / database based off of someone else's changes.
Easiest is to do the following:

1. `bundle install`
2. `rake db:drop db:create db:migrate db:seed`

## Testing

To run all the tests run: `rspec`

We have guard set up, so you can have guard automatically run your tests as you develop. To
 start guard run: `guard`. To quit enter `quit` in the guard prompt.


        END
      end
    end


    def run_all_updates
      clean_gemfile
      remove_turbo_links
      use_pg
      add_test_gems
      add_ruby_version
      install_rspec
      update_gitignore
      create_database_sample
      create_readme
    end
  end
end