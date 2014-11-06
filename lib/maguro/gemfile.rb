module Maguro
  class GemfileModifier
    attr_reader :ag, :file_name

    def initialize(app_generator)
      @ag = app_generator
      @file_name = "Gemfile"
    end

    def remove(regex, replacement)
      ag.gsub_file(file_name, regex, replacement )
    end

    def clean
      remove(/# .*[\r\n]?/, "")           #remove comments
      remove(/\n{2,}/, "\n")              #remove excess whitespace
    end
  end
end