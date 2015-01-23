require_relative '../../lib/maguro'
require 'rails/generators/rails/app/app_generator'
require 'tmpdir'
require 'fileutils'

describe Maguro do

  it 'creates a new application' do
    run_maguro_new("--hh=false --bb=false --gh=false")
    expect(File).to exist(project_path)
    expect(File).to exist("#{project_path}/README.md")
  end
end