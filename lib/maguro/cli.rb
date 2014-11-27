require 'thor'
require 'rails'

module Maguro
  class Cli < Thor
    include Thor::Actions

    register Maguro::AppGenerator, 'new', 'new APP_NAME', 'Creates a new rails app'
  end
end
