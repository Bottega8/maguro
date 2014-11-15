require_relative '../../lib/maguro/bitbucket'

describe Maguro::Bitbucket do

  describe '#get_repo' do
    it "returns the repo if found" do
      bb = Maguro::Bitbucket.new("quiz-app")
      expect(bb.repo['name']).to eq "quiz-app"
    end
  end

  describe '#create_repo' do
    it 'creates a new repo on bitbucket' do
      #Dont run for now...
      #
      # bb = Maguro::Bitbucket.new('test_app')
      # created_repo = bb.create_repo
      # expect(created_repo['name']).to eq 'test_app'
      #
      # #cleanup
      # bb.delete_repo
    end
  end

end