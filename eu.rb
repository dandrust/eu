# frozen_string_literal: true

module EU
  attr_reader :config

  def self.start(submodule, *args)
    submodule_class = 
      case submodule.to_sym
      when :registro
        EU::Registro
      when :config
        # Maybe change this to EU::Config::CLI
        EU::Config
      else
        puts "Submodule not found"
        #EU::Help
      end
    
    submodule_class.start(*args)
  end

  def self.config
    @config ||= EU::Config.load
  end
end

require_relative 'lib/config'
require_relative 'lib/registro'
