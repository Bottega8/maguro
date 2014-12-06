Dir[File.join(File.dirname(__FILE__),'maguro', '*.rb')].each { |file| require file }

module Maguro

  def self.organization
    @organization
  end

  def self.organization=(value)
    @organization = value
  end
  
  ## Basic base template
  def self.base_template(builder)
    features = Maguro::Features.new(builder, organization)
    features.run_all_updates
  end
end