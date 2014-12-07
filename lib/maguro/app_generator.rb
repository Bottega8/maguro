require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Maguro
  class AppGenerator < Rails::Generators::AppGenerator

    class_option :organization, :type => :string, :aliases => '-o',
                 :desc => 'Pass in your organization name to be used by heroku and bitbucket'

    # Overriding Rails::Generators::AppGenerator#finish_template to also run our custom code.
    def finish_template
      invoke :maguro_customizations
      super
    end

    def maguro_customizations
      set_organization
      Maguro.base_template(builder)
    end

    protected

    KEYCHAIN_ORGANIZATION='organization'

    def set_organization
      organization = options[:organization]

      saved_organization = Keychain.retrieve_account(KEYCHAIN_ORGANIZATION)
      saved_organization = saved_organization[:password] if saved_organization

      if organization
        Maguro.organization = organization
        org_output = saved_organization ? saved_organization : "<none>"

        if yes?("Save organization (y/n)? (current saved org: #{org_output}")
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