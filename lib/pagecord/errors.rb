# frozen_string_literal: true

module Pagecord
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ForbiddenError < Error; end
  class NotFoundError < Error; end
  class ValidationError < Error; end
  class RateLimitError < Error; end
end
