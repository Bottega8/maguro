require 'HTTParty'
require 'yaml'

module Maguro
  class Bitbucket
    include HTTParty

    attr_reader :app_name, :organization

    def initialize(app_name, organization)
      @app_name = app_name

      @organization = organization

      # Retrieve username and password from the OS X keychain,
      # via git's OS X credential manager
      output = %x[printf protocol=https\\\\nhost=bitbucket.org\\\\n\\\\n  | git credential-osxkeychain get]
      m = output.match("password=(.*)\n")
      throw "Failed to retrieve password from git credential-osxkeychain" if m.nil?
      password = m[1]
      
      m = output.match("username=(.*)\n")
      throw "Failed to retrieve username from git credential-osxkeychain" if m.nil?
      username = m[1]
      
      self.class.basic_auth username, password
      self.class.base_uri 'https://api.bitbucket.org/2.0'
    end

    def repo
      @repo ||= self.class.get("/repositories/#{organization}/#{app_name}")
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

      path = "/repositories/#{organization}/#{app_name}"
      response = self.class.post(path, options)
      if response['error']
        puts response['error']
        raise "There was an error creating the app."
      else
        repo
      end
    end

    def repo_git_url
      repo['links']['clone'].find {|link| link['name'] == 'ssh'}['href']
    end

    def delete_repo
      if app_name == 'test_app'
        self.class.delete("/repositories/#{organization}/test_app")
      else
        raise "Only allowed to deleted test_app. Mainly to clean up testing only."
      end
    end
  end
end