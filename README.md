
## Rails Application Templates for Bottega8


### Setup

Configure create a `config.yaml` file. Use `config.sample.yaml` as an example.
 Set username, password, and owner. Owner is the organization if you have one, or the
 same as the username (i think)

If you want to create heroku projects, make sure you have the heroku toolbelt installed.

### Usage

run: `rails new blog -m ./path/to/template.rb`

### Manual testing

testing: `rails new test_template -m ./template.rb`
removing test template folder: `trash -rf test_template`

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