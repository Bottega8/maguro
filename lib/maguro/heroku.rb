module Maguro
  class Heroku

    attr_reader :builder, :app_name, :organization, :production_name, :staging_name

    def initialize(builder, app_name, organization)
      @builder = builder
      @app_name = app_name.gsub(/[_ ]/,'-')
      @organization = organization
      @production_name = "#{@organization}-#{@app_name}"
      @staging_name = "#{@organization}-#{@app_name}-staging"
    end

    def create_app(app_name, remote_name)
      builder.run "heroku apps:create #{app_name} --remote #{remote_name}"
    end

    # https://addons.heroku.com/heroku-postgresql
    def add_database(app_name)
      builder.run "heroku addons:add heroku-postgresql --app #{app_name}"
    end

    # https://addons.heroku.com/pgbackups
    # length can be "week" or "month"
    def add_pg_backup(app_name, length="month")
      builder.run "heroku addons:add pgbackups:auto-#{length} --app #{app_name}"
    end

    def create
      create_app(staging_name, "staging")
      create_app(production_name, "production")

      add_database(staging_name)
      add_database(production_name)

      add_pg_backup(staging_name, "week")
      add_pg_backup(production_name)
    end

    def push
      builder.git push: "production master:master"
      builder.git push: "staging master:master"
    end
  end
end