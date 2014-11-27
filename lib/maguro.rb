Dir[File.join(File.dirname(__FILE__),'maguro', '*.rb')].each { |file| require file }

module Maguro

  # Global configuration
  RUBY_VERSION = '2.1.5'
  RAILS_VERSION = '4.1.8'

  def self.organization
    @organization
  end

  def self.organization=(value)
    @organization = value
  end
  
  ## Basic base template
  def self.base_template(project)
    features = Maguro::Features.new(project, organization)
    features.run_all_updates
  end
end