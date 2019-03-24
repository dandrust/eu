# frozen_string_literal: true

require 'yaml'

module EU
  class CacheService
    PATH = File.join(EU.path, "cache" )
    SEPARATOR = "__"

    private_class_method :new

    class << self
      attr_reader :path_exists
      
      # optional param: expires_in (days as integer)
      def set(key, value, options = {})
        ensure_path!
        remove(key)
        unless value.nil?
          expire_timestamp = timestamp(options[:expires_in])
          cache_key = full_key(key, expire_timestamp)
          File.write(cache_key, value.to_yaml)
        end
      end

      def get(key)
        ensure_path!
        if existing_cache = find_cache(key)
          YAML.load_file(existing_cache)
        end
      end

      def remove(key)
        if existing_cache = find_cache(key)
          File.delete(existing_cache)
        end
      end

      private

      def ensure_path!
        unless path_exists
          Dir.mkdir(PATH) unless Dir.exist?(PATH)
          @path_exists = true
        end
      end

      def full_key(key, timestamp)
        file = timestamp.nil? ? key.to_s : "#{key}#{SEPARATOR}#{timestamp}"
        File.join(PATH, file)
      end

      def find_cache(key)
        file = if !find_exact(key).nil?
          find_exact(key)
        else
          files = find_like(key)
          files = delete_expired(files)
          files.first
        end
        File.join(PATH, file)
      end

      def find_exact(key)
        Dir.glob(key.to_s, base: PATH).first
      end

      def find_like(key)
        Dir
          .glob("#{key}#{SEPARATOR}*", base: PATH)
          .reject {|file| timestamp_part(file).zero? }
      end

      def delete_expired(files)
        files.reject do |file|
          expiration = timestamp_part(file)
          if expiration < Time.now.to_i
            File.delete(file)
            true
          else
            false
          end
        end
      end

      def timestamp_part(file)
        file.split(SEPARATOR).last.to_i
      end

      def timestamp(days)
        if days.nil? || days.to_s == "never"
          nil
        else
          (Time.now + days * 60 * 60 * 24).to_i
        end
      end
    end
  end
end
