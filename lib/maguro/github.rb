module Maguro
  class Github

    attr_reader :builder, :app_name, :organization

    def initialize(builder, app_name, organization)
      @builder = builder
      @app_name = app_name
      @organization = organization
    end


    def git_url
      "git@github.com:#{organization}/#{app_name}.git"
    end

    # Will create a new repository on github and create a remote named origin.
    #
    def create_repo
      builder.run "hub create #{organization}/#{app_name}"
    end
  end
end