# frozen_string_literal: true

module EU
  class Registro
    private_class_method :new

    def self.start(*args)
      puts "nice job! you got here!"
      args.each do |arg|
        puts arg
      end
    end
  end
end

require_relative 'http_service'
require_relative 'harvest'
