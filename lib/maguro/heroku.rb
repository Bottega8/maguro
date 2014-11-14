module Maguro
  class Heroku

    attr_reader :project, :app_name

    def initialize(project, app_name)
      @project = project
      @app_name = app_name.gsub('_','-')
    end

    def create_staging
      project.run "heroku apps:create bottega8-#{app_name} --remote production"
    end

    def create_production
      project.run "heroku apps:create bottega8-#{app_name}-staging --remote staging"
    end

    def create
      create_staging
      create_production
    end
  end
end