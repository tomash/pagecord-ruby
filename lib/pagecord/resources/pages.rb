# frozen_string_literal: true

module Pagecord
  module Resources
    class Pages < Resource
      def list(status: nil, published_after: nil, published_before: nil, page: nil)
        http_get("/pages", query: { status:, published_after:, published_before:, page: })
      end

      def get(token)
        http_get("/pages/#{token}")
      end

      def create(title: nil, content: nil, content_format: nil, slug: nil, status: nil,
                 published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_post("/pages", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def update(token, title: nil, content: nil, content_format: nil, slug: nil, status: nil,
                 published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_patch("/pages/#{token}", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def delete(token)
        http_delete("/pages/#{token}")
      end
    end
  end
end
