
## Rails Application Templates for Bottega8


### Usage
Before running the Bottega8 Rails templates:
1. Install the [Heroku toolbelt](https://toolbelt.heroku.com/)
1. Install the Ruby Version Manager http://rvm.io/rvm/install
1. Create an account on BitBucket.org, and ensure you have access to Bottega8/maguro
1. Switch to directory where new project will live. E.g. `cd ~/Desktop/projects`
1. Set environment variable with app name `export APP_NAME=foobar`
1. Set the version of Ruby `rvm install ruby-2.1.5`
1. Create a gemset `rvm use 2.1.5@$APP_NAME --create`
1. Install the latest version of rails `gem install rails`
1. Clone this repository so the template will be available on your local machine `git clone https://bitbucket.org/bottega8/maguro $TMPDIR/maguro`
1. Set the BitBucket organization where the project's git repository will be hosted
`export ORGANIZATION=bottega8` (If you are using your personal account, set $ORGANIZATION to your username.)
1. Generate the new project: `rails new $APP_NAME -m $TEMPDIR/template.rb`

### Manual testing

testing: `rails new test_template -m $TEMPDIR/template.rb`
removing test template folder: `rm -rf test_template`

### template.rb

The Maguro `template.rb` will create a basic Rails project that is optimized for Bottega8's workflow. Th
Configurations include:

1. Remove Turbolinks
1. Use Postgres
1. Use and Configure Rspec + other testing gems
1. Set up some basic config stuff
1. Create file for app environment variables
1. Create a basic readme
1. Create a separate develop branch.

Optional:

1. Create a production and staging heroku application
1. Create a remote repo on bitbucket and push to it