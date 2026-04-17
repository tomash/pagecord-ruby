# frozen_string_literal: true

module Pagecord
  module Resources
    class HomePage < Resource
      def get
        http_get("/home_page")
      end

      def set(title: nil, content: nil, content_format: nil, slug: nil, status: nil,
              published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_post("/home_page", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def update(title: nil, content: nil, content_format: nil, slug: nil, status: nil,
                 published_at: nil, canonical_url: nil, tags: nil, hidden: nil, locale: nil)
        http_patch("/home_page", body: {
          title:, content:, content_format:, slug:, status:,
          published_at:, canonical_url:, tags:, hidden:, locale:
        }.compact)
      end

      def unlink
        http_delete("/home_page")
      end
    end
  end
end
