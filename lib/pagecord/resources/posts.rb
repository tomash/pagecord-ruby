# frozen_string_literal: true

module Pagecord
  module Resources
    class Posts < Resource
      def list(status: nil, published_after: nil, published_before: nil, page: nil)
        http_get("/posts", query: { status:, published_after:, published_before:, page: })
      end

      def get(token)
        http_get("/posts/#{token}")
      end

      def create(title: nil, content: nil, content_format: nil, slug: nil, status: nil,
                 published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_post("/posts", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def update(token, title: nil, content: nil, content_format: nil, slug: nil, status: nil,
                 published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_patch("/posts/#{token}", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def delete(token)
        http_delete("/posts/#{token}")
      end
    end
  end
end
