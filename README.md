
## Rails Application Templates for Bottega8

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

