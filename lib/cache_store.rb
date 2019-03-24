# frozen_string_literal: true

require 'yaml'

module EU
  class CacheStore
    PATH = File.join(EU.path, "cache" )

    private_class_method :new

    class << self
      attr_reader :path_exists
      
      def set(key, value)
        ensure_path!
        if value.nil?
          safe_delete(key)
        else
          File.write(cache_path(key), value.to_yaml)
        end
      end

      def get(key)
        ensure_path!
        YAML.load_file(cache_path(key)) if exist?(key)
      end

      def remove(key)
        safe_delete(key)
      end

      def exist?(key)
        File.exist?(cache_path(key))
      end

      private

      def cache_path(key)
        File.join(PATH, key.to_s)
      end

      def ensure_path!
        unless path_exists
          Dir.mkdir(PATH) unless Dir.exist?(PATH)
          @path_exists = true
        end
      end

      def safe_delete(key)
        file = cache_path(key)
        File.delete(file) if exist?(key)
      end
    end
  end
end
