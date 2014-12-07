
## Rails Application Templates for Bottega8

![alt tag](http://hajimefurukawa.com/random/img/maguro_sushi.jpg)

### Development and testing steps
To make local changes to this gem, clone this repository then:

1. Clone this repository
1. Run `bundle install` to install development dependencies
1. Develop/modify the source code
1. Run unit and integration tests with `rspec`
1. Build the gem `gem build maguro.gemspec`
1. Switch to the directory where you want to create a new project. E.g. `cd ~/Desktop/projects`
1. Install the gem `gem install ./maguro-0.0.1.gem`
1. Follow instructions in the section `Gem Usage`, i.e. `maguro new [APP_NAME]`


### Gem Prerequisites

Before running the Bottega8 Rails templates:

1. Install [PostgreSQL for OS X](http://www.postgresql.org/download/macosx/)
1. Install the [Heroku toolbelt](https://toolbelt.heroku.com/)
1. Install Ruby. We recommend using the [Ruby Version Manager](http://rvm.io/rvm/install)


### Gem Usage

1. Switch to directory where new project will live. E.g. `cd ~/Desktop/projects`
1. Install the maguro gem `gem install maguro`
1. Generate the new project: `maguro new $APP_NAME`
1. Open config/database.yml and replace `username` with the same username when setting up Postgres
1. Run `rake db:create db:migrate`

### What does the template do?

The Maguro project's `template.rb` will create a basic Rails project that is optimized for Bottega8's workflow by:

1. Saving RVM configuration files
1. Creating a basic README.md
1. Setting up local git repository, gitinit file, and development branch
1. Generating app_environment_variables.rb for custom environment variables
1. Removing Turbolinks
1. Including RSpec, capybara, database_cleaner, factory_girl, and other gems for testing
1. Using PostgreSQL as the database and generating database.yml
1. Optionally, creating Heroku applications for staging and production environments
1. Optionally, creating a Git repository on BitBucket.org, and pushing the newly-created Rails project to it
1. Optionally, securely storing BitBucket.org credentials in the OS X keychain for convenience
