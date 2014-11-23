require 'shellwords'

module Maguro
  class Keychain
    class << self
      
      def add_account(server, username, password)
        puts "Keychain: adding credentials with username #{username} for server #{server}"
        server = custom_server(server)

        # Try to delete existing password, in case it already exists
        delete_account(server)

        # Add the new password
        r = %x[security add-internet-password -a #{Shellwords::escape(username)} -s #{Shellwords::escape(server)} -w #{Shellwords::escape(password)} > /dev/null 2>&1]
      end

      def delete_account(server)
        puts "Keychain: attempting to remove credentials for #{server}"
        server = custom_server(server)

        # Suppress output, since command will expectedly fail if credentials have not yet been saved for the server
        r = %x[security delete-internet-password -s #{Shellwords::escape(server)} > /dev/null 2>&1]
      end
      
      def retrieve_account(server)
        puts "Keychain: attempting to retrieve credentials for #{server}"
        server = custom_server(server)

        # Retrieve the password from the keychain, but do not print it to STDOUT
        output = %x[security  2>&1 >/dev/null find-internet-password -gs #{Shellwords::escape(server)}]
        password = output[/^password: "(.*)"$/, 1]
        return nil if password.nil?

        output = %x[security find-internet-password -s #{Shellwords::escape(server)}]
        username = output[/"acct"<blob>="(.*)"$/, 1]
        return nil if username.nil?
        
        { username: username, password: password }
      end
      
      private
        PREFIX = "maguro-"
      
        # Use a custom prefix, so that Maguro's keychain entries will be separate
        # from any others in the Keychain (for the same domain)
        # Prepend the prefix, unless it has already been added
        def custom_server(server)
          "#{PREFIX}#{server}" if !server.start_with? PREFIX
        end
    end
  end
end