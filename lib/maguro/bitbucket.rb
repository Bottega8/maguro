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
          throw "Could not retrieve Git url for project #{app_name}"
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
        throw "Could not create Git repository for project #{app_name}"
      end
    end

    def bitbucket_api(path, method, options = {})
      puts "Making request to API at: #{path} via #{method} with options: #{options}"

      # First, try to read the username and password from the OS X Keychain
      if username.nil? && password.nil?
        output = %x[printf protocol=https\\\\nhost=bitbucket.org\\\\n\\\\n  | git credential-osxkeychain get]
        m = output.match("password=(.*)\n")
        self.password = m[1] if !m.nil?
        m = output.match("username=(.*)\n")
        self.username = m[1] if !m.nil?
      end

      # password = nil
      # username = nil

      tries = 0
      response = nil

      loop do

        tries += 1
    
        if username.nil? || password.nil?
          
          # Prompt the user for password
          puts ""
          puts ""
          self.username = project.ask "What is your BitBucket username?"
          puts ""
          # password = $stdin.noecho do
          #   ask "BitBucket password?"
          # end
          self.password = project.ask "What is your BitBucket password?", :echo => false
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
        return response if response_code == 200  # Success

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
        end
      end
  
      # The request was unsuccessful
      response
    end
  end

end