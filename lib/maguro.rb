Dir[File.join(File.dirname(__FILE__),'maguro', '*.rb')].each { |file| require file }


module Maguro

  # Global configuration
  RUBY_VERSION = '2.1.5'
  ORGANIZATION = "ORGANIZATION"
  
  ## Basic base template
  def self.base_template(project)
    # Read the ORGANIZATION environment variable from the command line
    raise "The environment variable #{ORGANIZATION} must be set. This value must correspond to the BitBucket account. Set it by running the command:   'export #{ORGANIZATION}=the_org_name'" if ENV[ORGANIZATION].nil?
    organization = ENV[ORGANIZATION]
    features = Maguro::Features.new(project, organization)
    features.run_all_updates
  end
end