require 'HTTParty'
require 'yaml'

module Maguro
  class Bitbucket
    include HTTParty

    attr_reader :app_name, :owner

    def initialize(app_name)
      @app_name = app_name

      config_file = File.expand_path('../../../config.yaml', __FILE__)
      data = YAML::load(File.open(config_file))

      @owner = data['owner']

      self.class.basic_auth data['username'], data['password']
      self.class.base_uri 'https://api.bitbucket.org/2.0'
    end

    def repo
      @repo ||= self.class.get("/repositories/#{owner}/#{app_name}")
    end

    def create_repo
      options = {
          body: {
              scm: 'git',
              name: app_name,
              is_private: true,
              fork_policy: 'no_public_forks',
              language: 'ruby'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
      }

      response = self.class.post("/repositories/#{owner}/#{app_name}", options)
      if response['error']
        puts response['error']
        raise "There was an error creating the app"
      else
        repo
      end
    end

    def repo_git_url
      repo['links']['clone'].find {|link| link['name'] == 'ssh'}['href']
    end

    def delete_repo
      if app_name == 'test_app'
        self.class.delete("/repositories/#{owner}/test_app")
      else
        raise "Only allowed to deleted test_app. Mainly to clean up testing only."
      end
    end
  end
end