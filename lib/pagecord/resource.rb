# frozen_string_literal: true

module Pagecord
  class Resource
    def initialize(client)
      @client = client
    end

    private

    def http_get(path, query: {})
      @client.request(:get, path, query: query.compact)
    end

    def http_post(path, body: {})
      @client.request(:post, path, body: body.to_json)
    end

    def http_patch(path, body: {})
      @client.request(:patch, path, body: body.to_json)
    end

    def http_delete(path)
      @client.request(:delete, path)
    end
  end
end
