require_relative '../../lib/maguro/bitbucket'
require_relative '../../lib/maguro/keychain'
require 'rails/generators/rails/app/app_generator'

describe Maguro::Bitbucket do

  describe '#get_repo' do
    it "returns the repo if found" do
      # Create generator, since it may be needed to prompt the user
      # for their BitBucket credentials
      project = Rails::Generators::AppGenerator.new(["."])
      
      app_name = "quiz-app"
      organization = "bottega8"
      bitbucket = Maguro::Bitbucket.new(project, app_name, organization)
        
      expect(bitbucket.git_url).to match /https:\/\/(.*)@bitbucket.org\/#{organization}\/quiz-app.git/
    end
  end

  describe '#create_repo' do
    it 'creates a new repo on bitbucket' do
      # TODO: Doug: How can we pass the organization to the generator and the tests (and other code)?
      organization = "bottega8"
      
      # Generate repository name that looks like: 
      #   test-41T5IGEW5YJ
      rando = (0..10).map {(('1'..'9').to_a + ('A'..'Z').to_a)[rand(36)]}.join.downcase
      app_name = "test-#{rando}"
      
      bitbucket = Maguro::Bitbucket.new(nil, app_name, organization)
      bitbucket.create_repo

      expect(bitbucket.git_url).to match /https:\/\/(.*)@bitbucket.org\/#{organization}\/#{app_name}.git/
      
      # Remove the repository from BitBucket
      bitbucket.delete_repo
      
      # Ensure that the repository has actually been deleted
      info = bitbucket.get_repo
      expect(info).to be_nil
    end
  end

end