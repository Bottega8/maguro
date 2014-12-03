module Maguro

  class Features
    attr_reader :builder, :gemfile, :app_name, :organization

    def initialize(builder, organization)
      @builder = builder
      @app_name = builder.send(:app_name)
      @gemfile = Maguro::Gemfile.new(builder)
      @organization = organization
    end

    def run_all_updates

      # TODO: Doug: check return value of commands? What happens if commands fail?
      # When git commands failed, the error is reported to the console, but the generator
      # completes successfully
      builder.git :init
      update_gitignore
      commit 'Initial commit with updated .gitignore'



      # Get user input at close to as possible to the invocation of 'rails new', while
      # the user's attention is still captured. Also, running this early 
      # makes debugging more convenient
      #
      # Don't setup Heroku or BitBucket if user runs 'rails new' with '--pretend'
      #
      # NOTE: Heroku setup has to come after initial init for it to create the proper
      # Git remotes.
      git_url = nil
      unless builder.options[:pretend]
        setup_heroku if builder.yes?('Setup Heroku (y/n)?')
        if builder.yes?('Setup BitBucket repo (y/n)?')
          git_url = setup_bitbucket
        end
      end

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
      
      if !git_url.nil?
        builder.git remote: "add origin #{git_url}"
        builder.git push: "-u origin --all"
      end

      checkout_develop_branch

    end

    private

    def create_rvm_files
      builder.create_file ".ruby-version" do
        <<-END.strip_heredoc
        #{Maguro::RUBY_VERSION}
        END
      end
    end

    def clean_gemfile
      gemfile.remove(/# .*[\r\n]?/, "")           #remove comments
      gemfile.remove(/\n{2,}/, "\n")              #remove excess whitespace
    end

    def add_ruby_version
      #add ruby version
      builder.insert_into_file "Gemfile", "ruby '#{Maguro::RUBY_VERSION}'\n", after: "source 'https://rubygems.org'\n"
    end

    def use_pg
      builder.gsub_file "Gemfile", /gem 'sqlite3'[\r\n]/, ""    # remove sqlite
      builder.gem 'pg'          # add new gems.
    end

    def use_12_factor_gem
      # For heroku
      builder.gem 'rails_12factor', group: :production
    end

    def remove_turbo_links
      # remove turbolinks
      builder.gsub_file "Gemfile", /gem 'turbolinks'[\r\n]/, ""

      # remove other code related to turbolinks
      builder.gsub_file "app/views/layouts/application.html.erb", /, ('|")data-turbolinks-track('|") => true/, ""
      builder.gsub_file "app/assets/javascripts/application.js", /\/\/= require turbolinks[\r\n]/, ""
    end

    def add_test_gems
      builder.gem_group :development, :test do
        gem 'awesome_print'
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
      builder.run "bundle install"
      builder.generate "rspec:install"
      builder.remove_dir "test"
    end


    # Update gitignore file with common stuff that we use.
    def update_gitignore
      builder.append_file ".gitignore" do
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

      builder.create_file "config/database.sample.yml" do
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

      builder.remove_file "config/database.yml"
      builder.run "cp config/database.sample.yml config/database.yml"
    end


    #create a README.md file
    def create_readme
      builder.remove_file "README.rdoc"
      builder.create_file "README.md" do
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
      builder.inside('spec') do
        %w{support models features factories}.each do |folder|
          builder.run "mkdir #{folder}"
          builder.run "touch ./#{folder}/.keep"
        end
      end
    end

    def update_rails_helper_spec
      file = 'spec/rails_helper.rb'

      #add rspec requires and poltergeist configuration
      builder.insert_into_file file, after: "# Add additional requires below this line. Rails is not loaded until this point!\n" do
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
      builder.gsub_file file, "# Dir[Rails.root.join(\"spec/support/**/*.rb\")].each { |f| require f }", "Dir[Rails.root.join(\"spec/support/**/*.rb\")].each { |f| require f }"

      #make transactional fixtures false
      builder.gsub_file file, "config.use_transactional_fixtures = true", "config.use_transactional_fixtures = false"

      #add database cleaner
      builder.insert_into_file file, after: "config.infer_spec_type_from_file_location!\n" do
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
      builder.create_file "config/app_environment_variables.sample.rb" do
        <<-END
# Add secret app environment variables in this file.
# You will also have to add these environment variables to heroku
# Make a copy of the .sample file but DON'T check it in! Only the sample should be checked in.
# ENV['MY_SAMPLE_SECRET'] = 'MYSECRETKEY'
        END
      end

      # make local copy of app_environment_variables file
      builder.run "cp config/app_environment_variables.sample.rb config/app_environment_variables.rb"

      # autoload environment variables into rails project
      builder.insert_into_file "config/environment.rb", after: "require File.expand_path('../application', __FILE__)\n" do
        <<-END

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)
        END
      end
    end

    def springify
      builder.run "bundle install"
      builder.run "bundle exec spring binstub --all"
    end

    def checkout_develop_branch
      builder.git checkout: '-b develop'
    end

    def commit(message)
      builder.run "bundle install"
      builder.git add: '--all .'
      builder.git commit: "-m '#{message}'"
    end

    def setup_heroku
      heroku = Maguro::Heroku.new(builder, app_name, organization)
      heroku.create
    end

    def setup_bitbucket
      clean_app_name = app_name.gsub(/[- ]/, '_')
      bitbucket = Maguro::Bitbucket.new(builder, clean_app_name, organization)
      bitbucket.create_repo
      bitbucket.git_url   
    end
  end
end