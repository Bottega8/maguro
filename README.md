
## Rails Application Templates for Bottega8


### Usage
Before running the Bottega8 Rails templates:
1. Install the [Heroku toolbelt](https://toolbelt.heroku.com/)
2. Create an account on BitBucket.org, and ensure you have access to Bottega8/maguro
3. Switch to directory where new project will live. E.g. `cd ~/Desktop/projects`
4. Use Bottega8's preferred version of Ruby: `rvm install ruby-2.1.3`
5. `rvm use 2.1.3`
6. `gem install rails`
7. `gem install httparty`
8. Clone this repository `git clone https://bitbucket.org/bottega8/maguro $TMPDIR/maguro`
9. Set the BitBucket organization where the project's git repoistory will be hosted
`export ORGANIZATION=bottega8`
10. Generate the new project: `rails new $APP_NAME -m $TEMPDIR/template.rb`

### Manual testing

testing: `rails new test_template -m $TEMPDIR/template.rb`
removing test template folder: `rm -rf test_template`

### template.rb

Using `template.rb` will create a basic rails app configured to how we start most projects.
Configurations include:

1. Remove Turbolinks
2. Use Postgres
3. Use and Configure Rspec + other testing gems
4. Set up some basic config stuff
5. Create file for app environment variables
6. Create a basic readme
7. Create's a separate develop branch.

Optional:

1. Create a production and staging heroku application
2. Create a remote repo on bitbucket and push to it