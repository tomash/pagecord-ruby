# frozen_string_literal: true

require "httparty"

module Pagecord
  class Client
    include HTTParty

    base_uri "https://api.pagecord.com"
    default_timeout 30
    format :json

    def initialize(api_key:)
      @api_key = api_key
    end

    def posts
      @posts ||= Resources::Posts.new(self)
    end

    def pages
      @pages ||= Resources::Pages.new(self)
    end

    def home_page
      @home_page ||= Resources::HomePage.new(self)
    end

    def attachments
      @attachments ||= Resources::Attachments.new(self)
    end

    def request(method, path, body: nil, query: nil, multipart: false)
      options = { headers: auth_headers }
      options[:headers]["Content-Type"] = "application/json" unless multipart
      options[:body] = body if body
      options[:query] = query if query && !query.empty?
      options[:multipart] = true if multipart

      http_response = self.class.send(method, path, options)
      handle_response(http_response)
    end

    private

    def auth_headers
      {
        "Authorization" => "Bearer #{@api_key}",
        "Accept" => "application/json"
      }
    end

    def handle_response(response)
      case response.code
      when 200..299 then Response.new(response)
      when 401 then raise AuthenticationError, error_message(response)
      when 403 then raise ForbiddenError, error_message(response)
      when 404 then raise NotFoundError, error_message(response)
      when 422 then raise ValidationError, error_message(response)
      when 429 then raise RateLimitError, "Rate limit exceeded (60 requests/minute per blog)"
      else raise Error, "HTTP #{response.code}: #{error_message(response)}"
      end
    end

    def error_message(response)
      response.parsed_response&.dig("error") || response.body
    end
  end
end
