# frozen_string_literal: true

module Pagecord
  class Response
    attr_reader :body, :total_count, :status

    def initialize(http_response)
      @http_response = http_response
      @status = http_response.code
      @body = http_response.parsed_response
      @total_count = http_response.headers["x-total-count"]&.to_i
    end

    def [](key)
      body[key.to_s]
    end

    def next_page_url
      link_relations["next"]
    end

    def prev_page_url
      link_relations["prev"]
    end

    def paginated?
      !total_count.nil?
    end

    def to_s
      body.to_s
    end

    def inspect
      "#<Pagecord::Response status=#{status} total_count=#{total_count} body=#{body.inspect}>"
    end

    private

    def link_relations
      @link_relations ||= begin
        link_header = @http_response.headers["link"] || ""
        link_header.scan(/<([^>]+)>;\s*rel="([^"]+)"/)
                   .each_with_object({}) { |(url, rel), memo| memo[rel] = url }
      end
    end
  end
end
