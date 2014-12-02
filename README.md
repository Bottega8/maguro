
## Rails Application Templates for Bottega8

![alt tag](http://hajimefurukawa.com/random/img/maguro_sushi.jpg)

### Prerequisite

Before running the Bottega8 Rails templates:

1. Install [PostgreSQL for OS X](http://www.postgresql.org/download/macosx/)
1. Install the [Heroku toolbelt](https://toolbelt.heroku.com/)
1. Install Ruby. We recommend using the [Ruby Version Manager](http://rvm.io/rvm/install)


### Usage

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
 
### Testing the template

The template can be testing by running its test specs:

1. `rspec`
2. When prompted, enter your Bitbucket credentials

### Development

Running the new gem:

Build: `gem build maguro.gemspec`
Install: `gem install ./maguro-0.0.1.gem`
Run: `maguro new [APP_NAME]`
