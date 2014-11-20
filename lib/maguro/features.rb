require 'byebug'
module Maguro

  class Features
    attr_reader :project, :gemfile, :app_name, :organization

    def initialize(new_project, organization)
      @project = new_project
      @app_name = project.send(:app_name)
      @gemfile = Maguro::Gemfile.new(new_project)
      @organization = organization
    end

    def run_all_updates

      project.git :init
      update_gitignore
      commit 'Initial commit with updated .gitignore'

      create_rvm_files

      clean_gemfile
      use_pg
      use_12_factor_gem
      add_test_gems
      add_ruby_version
      commit 'add gems'

      remove_turbo_links
      commit 'remove turbolinks'


      create_database_sample
      commit 'add database.sample file'
      create_readme
      commit 'add readme'
      create_app_env_var_sample
      commit 'add app environment variable sample file'

      install_rspec
      commit 'install rspec'

      create_spec_folders
      update_rails_helper_spec
      commit 'customize rspec for basic usage'

      springify
      commit 'springify app'

      checkout_develop_branch

      # Don't setup Heroku or BitBucket if user runs 'rails new' with '--pretend'
      unless project.options[:pretend]
        setup_heroku if project.yes?('Setup Heroku (y/n)?')
        setup_bitbucket if project.yes?('Setup BitBucket repo (y/n)?')
      end
    end

    private

    def create_rvm_files
      project.create_file ".ruby-version" do 
        <<-END.strip_heredoc
        #{Maguro::RUBY_VERSION}
        END
      end
      
      project.create_file ".ruby-gemset" do
        <<-END.strip_heredoc
        #{app_name}
        END
      end
    end

    def clean_gemfile
      gemfile.remove(/# .*[\r\n]?/, "")           #remove comments
      gemfile.remove(/\n{2,}/, "\n")              #remove excess whitespace
    end

    def add_ruby_version
      #add ruby version
      project.insert_into_file "Gemfile", "ruby '#{Maguro::RUBY_VERSION}'\n", after: "source 'https://rubygems.org'\n"
    end

    def use_pg
      project.gsub_file "Gemfile", /gem 'sqlite3'[\r\n]/, ""    # remove sqlite
      project.gem 'pg'          # add new gems.
    end

    def use_12_factor_gem
      # For heroku
      project.gem 'rails_12factor', group: :production
    end

    def remove_turbo_links
      # remove turbolinks
      project.gsub_file "Gemfile", /gem 'turbolinks'[\r\n]/, ""

      # remove other code related to turbolinks
      project.gsub_file "app/views/layouts/application.html.erb", /, ('|")data-turbolinks-track('|") => true/, ""
      project.gsub_file "app/assets/javascripts/application.js", /\/\/= require turbolinks[\r\n]/, ""
    end

    def add_test_gems
      project.gem_group :development, :test do
        gem 'awesome_print'
        gem 'rspec-rails'
        gem 'capybara'
        gem 'database_cleaner'
        gem 'factory_girl_rails'
        gem 'faker'
        gem 'guard'
        gem 'guard-bundler', require: false
        gem 'guard-rspec', require: false
        gem 'poltergeist'
        gem 'pry'
        gem 'rb-inotify', require: false
        gem 'rb-fsevent', require: false
        gem 'rb-fchange', require: false
        gem 'rspec-rails'
        gem 'rspec-collection_matchers'
        gem 'shoulda-matchers'
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
        /config/app_environment_variables.rb
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

    def create_spec_folders
      project.inside('spec') do
        %w{support models features factories}.each do |folder|
          project.run "mkdir #{folder}"
          project.run "touch ./#{folder}/.keep"
        end
      end
    end

    def update_rails_helper_spec
      file = 'spec/rails_helper.rb'

      #add rspec requires and poltergeist configuration
      project.insert_into_file file, after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
        <<-END
require 'rspec/collection_matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'

Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 5
        END
      end

      #autoload all support files
      project.gsub_file file, "# Dir[Rails.root.join(\"spec/support/**/*.rb\")].each { |f| require f }", "Dir[Rails.root.join(\"spec/support/**/*.rb\")].each { |f| require f }"

      #make transactional fixtures false
      project.gsub_file file, "config.use_transactional_fixtures = true", "config.use_transactional_fixtures = false"

      #add database cleaner
      project.insert_into_file file, after: "config.infer_spec_type_from_file_location!\n" do
        <<-END


  # Configure standard database cleaner. Use truncation instead of transactions.
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
        END
      end
    end

    def create_app_env_var_sample
      # create sample of app_environment_variables file
      project.create_file "config/app_environment_variables.sample.rb" do
        <<-END
# Add secret app environment variables in this file.
# You will also have to add these environment variables to heroku
# Make a copy of the .sample file but DON'T check it in! Only the sample should be checked in.
# ENV['MY_SAMPLE_SECRET'] = 'MYSECRETKEY'
        END
      end

      # make local copy of app_environment_variables file
      project.run "cp config/app_environment_variables.sample.rb config/app_environment_variables.rb"

      # autoload environment variables into rails project
      project.insert_into_file "config/environment.rb", after: "require File.expand_path('../application', __FILE__)\n" do
        <<-END

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)
        END
      end
    end

    def springify
      project.run "bundle install"
      project.run "bundle exec spring binstub --all"
    end

    def checkout_develop_branch
      project.git checkout: '-b develop'
    end

    def commit(message)
      project.run "bundle install"
      project.git add: '--all .'
      project.git commit: "-m '#{message}'"
    end

    def setup_heroku
      heroku = Maguro::Heroku.new(project, app_name, organization)
      heroku.create
    end

    def setup_bitbucket
      clean_app_name = app_name.gsub(/[- ]/, '_')
      bitbucket = Maguro::Bitbucket.new(project, clean_app_name, organization)
      bitbucket.create_repo
      project.git remote: "add origin #{bitbucket.git_url}"
      project.git push: "-u origin --all"
    end
  end
end