require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Maguro
  class AppGenerator < Rails::Generators::AppGenerator

    class_option :organization, type: :string, aliases: '-o',
                 desc: 'Pass in your organization name to be used by heroku and bitbucket'

    class_option :heroku, type: :boolean,
                 desc: 'Create a production and staging heroku application'

    class_option :bitbucket, type: :boolean,
                 desc: 'Create a bitbucket project and push to it.'

    # Overriding Rails::Generators::AppGenerator#finish_template.
    # Allows maguro to do stuff before the default rails generator is run.
    #
    def initialize(*args)
      super

      # Thor's option hash is frozen. Unfreeze so we can update our own variables on it.
      # Risk: Don't accidentally modify options you didn't mean to!
      self.options = options.dup

      set_custom_options
    end


    # Overriding Rails::Generators::AppGenerator#finish_template.
    # This will run our maguro customizations after all of the default rails customizations.
    def finish_template
      Maguro.base_template(builder)
      super
    end

    protected

    def set_custom_options

      #skip heroku and bitbucket if --pretend is passed.
      if options[:pretend]
        options[:heroku] = false
        options[:bitbucket] = false
      else
        # Prompt user if they haven't passed in a value for heroku, bitbucket options.
        if options[:heroku].nil?
          options[:heroku] = builder.yes?('Setup Heroku (y/n)?')
        end
        if options[:bitbucket].nil?
          options[:bitbucket] = builder.yes?('Setup BitBucket repo (y/n)?')
        end
      end

      # only worry about setting organization if we are using heroku or bitbucket
      if options[:heroku] || options[:bitbucket]
        set_organization
      end
    end


    KEYCHAIN_ORGANIZATION='organization'

    def set_organization
      organization = options[:organization]

      saved_organization = Keychain.retrieve_account(KEYCHAIN_ORGANIZATION)
      saved_organization = saved_organization[:password] if saved_organization

      if organization
        Maguro.organization = organization
        org_output = saved_organization ? saved_organization : "<none>"

        if yes?("Save organization '#{organization}' as default (y/n)? (current default: #{org_output})")
          Keychain.add_account(KEYCHAIN_ORGANIZATION, KEYCHAIN_ORGANIZATION, organization)
        end
      elsif saved_organization
        if yes?("Use saved organization, #{saved_organization} (y/n)?")
          Maguro.organization = saved_organization
        else
          raise Thor::InvocationError, "Organization was not set. Please set organization with '-o ORGANIZATION'"
        end
      else
        raise Thor::InvocationError, "Organization was not set. Please set organization with '-o ORGANIZATION'"
      end
    end
  end
end