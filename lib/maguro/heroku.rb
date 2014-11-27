module Maguro
  class Heroku

    attr_reader :builder, :app_name, :organization

    def initialize(builder, app_name, organization)
      @builder = builder
      @app_name = app_name.gsub(/[_ ]/,'-')
      @organization = organization
    end

    def create_staging
      builder.run "heroku apps:create #{organization}-#{app_name} --remote production"
    end

    def create_production
      builder.run "heroku apps:create #{organization}-#{app_name}-staging --remote staging"
    end

    def create
      create_staging
      create_production
    end
  end
end