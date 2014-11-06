Dir[File.join(File.dirname(__FILE__),'maguro', '*.rb')].each { |file| require file }

module Maguro

  #Variables that
  RUBY_VERSION = '2.1.3'

  ## Basic base template
  def self.base_template(project)
    features = Maguro::Features.new(project)
    features.run_all_updates
  end
end