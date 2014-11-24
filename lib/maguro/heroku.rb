module Maguro
  class Heroku

    attr_reader :project, :app_name, :organization

    def initialize(project, app_name, organization)
      @project = project
      @app_name = app_name.gsub(/[_ ]/,'-')
      @organization = organization
    end

    def create_staging
      project.run "heroku apps:create #{organization}-#{app_name} --remote production"
    end

    def create_production
      project.run "heroku apps:create #{organization}-#{app_name}-staging --remote staging"
    end

    def create
      create_staging
      create_production
    end
  end
end