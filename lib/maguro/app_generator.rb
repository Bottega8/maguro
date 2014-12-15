require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Maguro
  class AppGenerator < Rails::Generators::AppGenerator



    class_option :heroku, type: :boolean, aliases: '--hh',
                 desc: 'Create a production and staging heroku application'

    class_option :bitbucket, type: :boolean, aliases: '--bb',
                 desc: 'Create a bitbucket project and push to it.'

    class_option :github, type: :boolean, aliases: '--gh',
                 desc: 'Create a github project and push to it.'

    class_option :organization, type: :string, aliases: '-o',
                 desc: 'Pass in your organization name to be used by heroku and bitbucket'

    class_option :'database-username', type: :string, aliases: '--du',
                 desc: 'Add a database username'

    class_option :'database-password', type: :string, aliases: '--dp',
                 desc: 'Add a database password'

    # Overriding Rails::Generators::AppGenerator#finish_template.
    # Allows maguro to do stuff before the default rails generator is run.
    #
    def initialize(*args)
      super

      check_ruby_version

      # Thor's option hash is frozen. Unfreeze so we can update our own variables on it.
      # Risk: Don't accidentally modify options you didn't mean to!
      self.options = options.dup

      set_custom_options
    end


    # Overriding Rails::Generators::AppGenerator#finish_template.
    # This will run our maguro customizations after all of the default rails customizations.
    def finish_template
      Maguro::Features.new(builder).run_all_updates

      super
    end

    protected

    def check_ruby_version
      if ::RUBY_VERSION != Maguro::RUBY_VERSION
        raise Thor::Error, "You are using ruby version #{::RUBY_VERSION}. Maguro requires ruby version #{Maguro::RUBY_VERSION}. (e.g. rvm use #{Maguro::RUBY_VERSION})."
      end
    end

    def set_custom_options

      #skip heroku and bitbucket if --pretend is passed.
      if options[:pretend]
        options[:heroku] = false
        options[:bitbucket] = false
        options[:github] = false
      else
        # Prompt user if they haven't passed in a value for heroku, bitbucket options.
        if options[:heroku].nil?
          options[:heroku] = builder.yes?('Setup Heroku (y/n)?')
        end
        if options[:bitbucket].nil?
          options[:bitbucket] = builder.yes?('Setup BitBucket repo (y/n)?')
        end
        if options[:github].nil?
          options[:github] = builder.yes?('Setup Github repo (y/n)?')
        end
      end

      if options[:bitbucket] && options[:github]
        raise Thor::Error, "Can't set up both bitbucket and github :p. (Select one)"
      end

      # only worry about setting organization if we are using heroku or bitbucket
      if options[:heroku] || options[:bitbucket] || options[:github]
        set_organization
      end
    end


    KEYCHAIN_ORGANIZATION='organization'

    def set_organization
      saved_organization = Keychain.retrieve_account(KEYCHAIN_ORGANIZATION)
      saved_organization = saved_organization[:password] if saved_organization

      if options[:organization]
        org_output = saved_organization ? saved_organization : "<none>"

        if yes?("Save organization '#{options[:organization]}' as default (y/n)? (current default: #{org_output})")
          Keychain.add_account(KEYCHAIN_ORGANIZATION, KEYCHAIN_ORGANIZATION, options[:organization])
        end
      elsif saved_organization
        if yes?("Use saved organization, #{saved_organization} (y/n)?")
          options[:organization] = saved_organization
        else
          raise Thor::InvocationError, "Organization was not set. Please set organization with '-o ORGANIZATION'"
        end
      else
        raise Thor::InvocationError, "Organization was not set. Please set organization with '-o ORGANIZATION'"
      end
    end
  end
end