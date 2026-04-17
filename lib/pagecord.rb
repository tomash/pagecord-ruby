# frozen_string_literal: true

require_relative "pagecord/version"
require_relative "pagecord/errors"
require_relative "pagecord/response"
require_relative "pagecord/resource"
require_relative "pagecord/resources/posts"
require_relative "pagecord/resources/pages"
require_relative "pagecord/resources/home_page"
require_relative "pagecord/resources/attachments"
require_relative "pagecord/client"

module Pagecord
  def self.new(api_key:)
    Client.new(api_key:)
  end
end
