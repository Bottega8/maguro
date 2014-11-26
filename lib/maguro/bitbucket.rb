require 'net/http'
require 'net/https'
require 'uri'
require 'json'

module Maguro
  class Bitbucket
    protected
    attr_accessor :username, :password
    
    public
    attr_reader :project, :app_name, :organization

    BITBUCKET = "bitbucket.org"
    API_BASE = "https://api.bitbucket.org/2.0"
    
    def initialize(project, app_name, organization)
      @project = project
      @app_name = app_name
      @organization = organization
      self.username = nil
      self.password = nil
    end

    def git_url
      if @git_url.nil?
        path = "#{API_BASE}/repositories/#{organization}/#{app_name}"
        response = bitbucket_api(path, Net::HTTP::Get)
        
        if response.code == "200"
          @git_url = JSON.parse(response.body)["links"]["clone"].find{|i| i["name"] == "https"}["href"]
        else
          raise "Could not retrieve Git url for project #{app_name}"
        end
      end
      @git_url
    end

    def create_repo
      options = {
        scm:          'git',
        name:         app_name,
        is_private:   true,
        fork_policy:  'no_public_forks',
        language:     'ruby'
      }

      path = "#{API_BASE}/repositories/#{organization}/#{app_name}"
      response = bitbucket_api(path, Net::HTTP::Post, options)

      if response.code == "200"
        # Success
        puts "Successfully created repository for #{app_name}"
      else
        raise "Could not create Git repository for project #{app_name}"
      end
    end

    def delete_repo
      path = "#{API_BASE}/repositories/#{organization}/#{app_name}"
      success_code = 204
      response = bitbucket_api(path, Net::HTTP::Delete, {}, success_code)
      raise "Could not delete repository." if response.code != success_code.to_s
      puts "Successfully deleted repository: '#{app_name}'"
    end
    
    def get_repo
      path = "#{API_BASE}/repositories/#{organization}/#{app_name}"
      response = bitbucket_api(path, Net::HTTP::Get)

      # Do not raise on error, so that this method can be used
      # to query the existence of a repository
      return nil if response.code != "200"

      JSON.parse(response.body)
    end
    
    
    private
    def bitbucket_api(path, method, options = {}, expected_http_code = 200)
      puts "Making request to API at: #{path} via #{method} with options: #{options}"

      # TODO: Doug: do we want to enable this?
      # First, try to read the username and password from the OS X Keychain,
      # as stored by git credential-oskeychain
      # if username.nil? || password.nil?
      #   output = %x[printf protocol=https\\\\nhost=#{BITBUCKET}\\\\n\\\\n  | git credential-osxkeychain get]
      #   m = output.match("password=(.*)\n")
      #   self.password = m[1] if !m.nil?
      #   m = output.match("username=(.*)\n")
      #   self.username = m[1] if !m.nil?
      # end
      
      # Try to retrieve username and password directly from the OS X Keychain
      did_get_password_from_keychain = false
      if username.nil? || password.nil?
        credentials = Keychain.retrieve_account(BITBUCKET)
        if !credentials.nil?
          self.username = credentials[:username]
          self.password = credentials[:password]
          did_get_password_from_keychain = true
        end
      end

      tries = 0
      response = nil
      should_store_in_keychain = false

      loop do

        tries += 1
    
        if username.nil? || password.nil?
          
          # Prompt the user for password
          puts ""
          self.username = project.ask "What is your BitBucket username?"
          puts ""
          # password = $stdin.noecho do
          #   ask "BitBucket password?"
          # end
          self.password = project.ask "What is your BitBucket password?", :echo => false
          puts ""
          puts ""

          if did_get_password_from_keychain || (project.yes? "Do you want to store this BitBucket login info into the Keychain? (y/n)")
            should_store_in_keychain = true 
          end
          puts ""
        end

        url = URI.parse(path)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')

        request = method.new(url.path)
        if !options.empty?
          request["content-type"] = "application/json"
          request.body = options.to_json
        end

        request.basic_auth username, password

        response = http.request(request)
  
        response_code = response.code.to_i
        
        # Most REST calls return HTTP 200 on success.
        # Some calls return another status code on success,
        # E.g. DELETE returns 204
        if response_code == expected_http_code  # Success
          Keychain.add_account(BITBUCKET, username, password) if should_store_in_keychain
          return response
        end

        puts "Response code: #{response_code} message: #{response.message}"
        if !response.body.empty?
          message = JSON.parse(response.body)["error"]["message"]
          detail = JSON.parse(response.body)["error"]["detail"]
          puts "Error message: #{message}"
          puts "Error detail: #{detail}" if !detail.nil?
        end

        break if tries >= 3  # Try no more than three times
        break if response_code != 401 # Only retry when the username/password is incorrect
    
        # Clear password, so the next iteration of the loop will prompt the user
        if response_code == 401
          self.username = nil
          self.password = nil
          
          if did_get_password_from_keychain
            # If we got credentials from the Keychain, and authentication fails,
            # clear the credentials from the keychain
            Keychain.delete_account(BITBUCKET)
          end
        end
      end
  
      # The request was unsuccessful
      response
    end
  end

end