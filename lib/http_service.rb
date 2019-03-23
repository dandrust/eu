# frozen_string_literal: true

require 'net/http'
require 'openssl'

module EU
  class HTTPService
    attr_reader :uri, :headers, :client

    def initialize(uri, headers = {})
      @uri = URI.parse(uri.to_s)
      @headers = headers
      @client = Net::HTTP.new(@uri.host, @uri.port)
      if @uri.port = 443
        @client.use_ssl = true
        @client.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      # Perhaps include a response parser (strategy)
      # that could wrap the API response
    end

    def get(path)
      request = Net::HTTP::Get.new(path, headers)
      response = client.request(request)
    end
  end
end
