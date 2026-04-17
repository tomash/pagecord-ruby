# frozen_string_literal: true

module Pagecord
  module Resources
    class Attachments < Resource
      # Accepts a file path (String) or an IO object.
      # Returns a Response whose body includes `attachable_sgid` and `url`.
      def upload(file)
        file_io = file.is_a?(String) ? File.new(file, "rb") : file
        @client.request(:post, "/attachments",
          body: { file: file_io },
          multipart: true)
      end
    end
  end
end
