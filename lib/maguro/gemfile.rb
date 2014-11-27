module Maguro
  class Gemfile
    attr_reader :builder, :file_name

    def initialize(builder)
      @builder = builder
      @file_name = "Gemfile"
    end

    def remove(regex, replacement)
      builder.gsub_file(file_name, regex, replacement)
    end
  end
end