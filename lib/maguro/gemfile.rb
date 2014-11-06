module Maguro
  class Gemfile
    attr_reader :project, :file_name

    def initialize(app_generator)
      @project = app_generator
      @file_name = "Gemfile"
    end

    def remove(regex, replacement)
      project.gsub_file(file_name, regex, replacement)
    end
  end
end