# frozen_string_literal: true

require 'yaml'

module EU
  class Config
    DOTFILE = File.join(Dir.home, '.eu')

    private_class_method :new

    attr_reader :instance, :config, :dirty

    def self.load
      @instance ||= new
    end

    # Access point for CLI
    def self.start(key, value, *args)
      # This probably needs the ability to 
      # set and unset values
      self.load.set(key, value)
    end

    def set(key, value)
      @config[key.to_s] = value
      @dirty = true
      write_config
      reload_config
    end

    def initialize
      ensure_dotfile
      reload_config
    end

    private

    def reload_config
      @config = YAML.load_file(DOTFILE)
      @config.keys.each do |key|
        instance_variable_set "@#{key}", @config[key]
        self.class.attr_reader key.to_sym
      end
    end

    def write_config
      return unless dirty
      File.write(DOTFILE, config.to_yaml)
      @dirty = false
    end

    def dotfile_exists?
      File.exist?(DOTFILE)
    end

    def ensure_dotfile
      File.write(DOTFILE, "") unless dotfile_exists?
    end

  end
end


