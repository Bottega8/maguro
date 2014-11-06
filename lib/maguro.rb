Dir[File.join(File.dirname(__FILE__),'maguro', '*.rb')].each { |file| require file }

module Maguro

  ## Basic base template
  def self.base_template(generator_instance)
    gm = Maguro::GemfileModifier.new(generator_instance)
    gm.clean
  end
end