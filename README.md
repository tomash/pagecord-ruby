# pagecord-ruby

Simple Ruby wrapper library for the [Pagecord](https://pagecord.com) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pagecord-ruby'
```

And then execute:

```bash
bundle install
```

## Getting Started

First, get your API key from your Pagecord blog settings.

Then initialize the client:

```ruby
require 'pagecord'

client = Pagecord.new(api_key: "your_api_key")
```

## Resources

### Posts

#### List posts

```ruby
response = client.posts.list
response.body # => [{"token" => "abc", "title" => "Hello", ...}]
response.total_count # => 1

# With filters
client.posts.list(status: "published", published_after: "2024-01-01", page: 2)
```

#### Get a post

```ruby
response = client.posts.get("abc123")
response["title"] # => "My Post"
```

#### Create a post

```ruby
response = client.posts.create(
  title: "My New Post",
  content: "<p>Hello world</p>",
  content_format: "html",  # or "markdown"
  status: "published",     # or "draft"
  slug: "my-new-post",
  tags: ["ruby", "api"],
  canonical_url: "https://example.com/original",
  hidden: false,
  locale: "en"
)
response["token"] # => "xyz789"
```

#### Update a post

```ruby
response = client.posts.update(
  "abc123",
  title: "Updated Title",
  status: "draft"
)
```

#### Delete a post

```ruby
client.posts.delete("abc123")
```

### Pages

Pages work exactly like posts:

```ruby
# List pages
client.pages.list

# Get a page
client.pages.get("page-token")

# Create a page
client.pages.create(title: "About", content: "<p>About me...</p>")

# Update a page
client.pages.update("page-token", title: "About Us")

# Delete a page
client.pages.delete("page-token")
```

### Home Page

```ruby
# Get the current home page
client.home_page.get

# Set (create) the home page
client.home_page.set(title: "Welcome", content: "<p>Welcome to my blog!</p>")

# Update the home page
client.home_page.update(title: "New Welcome")

# Unlink (remove) the home page
client.home_page.unlink
```

### Attachments

Upload files to include in your posts:

```ruby
# Upload by file path
response = client.attachments.upload("/path/to/image.png")

# Upload with an IO object
response = client.attachments.upload(File.open("image.png"))

# The response contains the attachment info
response["attachable_sgid"] # => "BAh7..."
response["url"]             # => "https://cdn.pagecord.com/..."
```

## Pagination

List responses may be paginated. Check for pagination info:

```ruby
response = client.posts.list

if response.paginated?
  response.total_count  # Total number of items
  response.next_page_url # URL for next page (nil if no next page)
  response.prev_page_url # URL for previous page (nil if no prev page)
end
```

## Error Handling

The library raises specific exceptions for different error conditions:

```ruby
begin
  client.posts.get("non-existent")
rescue Pagecord::AuthenticationError
  # API key is invalid
rescue Pagecord::NotFoundError
  # Resource doesn't exist
rescue Pagecord::ValidationError
  # Invalid data submitted
rescue Pagecord::RateLimitError
  # Rate limit exceeded (60 requests/minute per blog)
rescue Pagecord::ForbiddenError
  # Insufficient permissions
rescue Pagecord::Error
  # Base error class - catches all above
end
```

## Rate Limiting

The Pagecord API allows 60 requests per minute per blog. If you exceed this limit, a `Pagecord::RateLimitError` will be raised.

## Official API Documentation

For complete API details, visit: https://help.pagecord.com/api
