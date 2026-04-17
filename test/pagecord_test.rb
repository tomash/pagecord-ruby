# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require "stringio"
require_relative "../lib/pagecord"

class PagcordTest < Minitest::Test
  BASE = "https://api.pagecord.com"
  KEY  = "test_secret"

  def setup
    @client = Pagecord.new(api_key: KEY)
  end

  # --- helpers ---

  def stub_api(method, path, body, status: 200, headers: {})
    stub_request(method, "#{BASE}#{path}")
      .with(headers: { "Authorization" => "Bearer #{KEY}" })
      .to_return(
        status: status,
        body: body.to_json,
        headers: { "Content-Type" => "application/json" }.merge(headers)
      )
  end

  # --- posts ---

  def test_posts_list
    stub_api(:get, "/posts", [{ "token" => "abc", "title" => "Hello" }],
             headers: { "X-Total-Count" => "1" })
    response = @client.posts.list
    assert_equal "Hello", response.body.first["title"]
    assert_equal 1, response.total_count
  end

  def test_posts_list_forwards_filters
    stub_request(:get, "#{BASE}/posts")
      .with(query: hash_including("status" => "published", "page" => "2"),
            headers: { "Authorization" => "Bearer #{KEY}" })
      .to_return(status: 200, body: [].to_json, headers: { "Content-Type" => "application/json" })
    @client.posts.list(status: "published", page: 2)
    # WebMock raises if params didn't match — reaching here is the assertion
  end

  def test_posts_get
    stub_api(:get, "/posts/abc123", { "token" => "abc123", "title" => "My Post" })
    response = @client.posts.get("abc123")
    assert_equal "My Post", response["title"]
  end

  def test_posts_create
    stub_api(:post, "/posts", { "token" => "new1", "title" => "Draft" }, status: 201)
    response = @client.posts.create(title: "Draft", content: "<p>Hi</p>", status: "draft")
    assert_equal "new1", response["token"]
  end

  def test_posts_update
    stub_api(:patch, "/posts/abc123", { "token" => "abc123", "status" => "published" })
    response = @client.posts.update("abc123", status: "published")
    assert_equal "published", response["status"]
  end

  def test_posts_delete
    stub_api(:delete, "/posts/abc123", {})
    @client.posts.delete("abc123")
    assert_requested :delete, "#{BASE}/posts/abc123"
  end

  # --- pages (confirms identical resource pattern works) ---

  def test_pages_list
    stub_api(:get, "/pages", [{ "token" => "p1", "title" => "About" }])
    response = @client.pages.list
    assert_equal "About", response.body.first["title"]
  end

  def test_pages_get
    stub_api(:get, "/pages/p1", { "token" => "p1", "title" => "About" })
    response = @client.pages.get("p1")
    assert_equal "About", response["title"]
  end

  # --- home page ---

  def test_home_page_get
    stub_api(:get, "/home_page", { "title" => "Welcome" })
    assert_equal "Welcome", @client.home_page.get["title"]
  end

  def test_home_page_set
    stub_api(:post, "/home_page", { "title" => "Home" }, status: 201)
    assert_equal "Home", @client.home_page.set(title: "Home")["title"]
  end

  def test_home_page_update
    stub_api(:patch, "/home_page", { "title" => "New Title" })
    assert_equal "New Title", @client.home_page.update(title: "New Title")["title"]
  end

  def test_home_page_unlink
    stub_api(:delete, "/home_page", {})
    @client.home_page.unlink
    assert_requested :delete, "#{BASE}/home_page"
  end

  # --- attachments ---

  def test_attachments_upload
    stub_request(:post, "#{BASE}/attachments")
      .with(headers: { "Authorization" => "Bearer #{KEY}" })
      .to_return(status: 201,
                 body: { "attachable_sgid" => "BAh7abc", "url" => "https://cdn.example.com/img.png" }.to_json,
                 headers: { "Content-Type" => "application/json" })
    response = @client.attachments.upload(StringIO.new("fake bytes"))
    assert_equal "BAh7abc", response["attachable_sgid"]
    assert_equal "https://cdn.example.com/img.png", response["url"]
  end

  # --- response: pagination ---

  def test_response_pagination
    link = '<https://api.pagecord.com/posts?page=3>; rel="next", ' \
           '<https://api.pagecord.com/posts?page=1>; rel="prev"'
    stub_api(:get, "/posts", [], headers: { "X-Total-Count" => "60", "Link" => link })
    response = @client.posts.list
    assert_equal 60, response.total_count
    assert_includes response.next_page_url, "page=3"
    assert_includes response.prev_page_url, "page=1"
  end

  # --- errors ---

  def test_raises_authentication_error_on_401
    stub_api(:get, "/posts", { "error" => "Unauthorized" }, status: 401)
    assert_raises(Pagecord::AuthenticationError) { @client.posts.list }
  end

  def test_raises_not_found_error_on_404
    stub_api(:get, "/posts/missing", { "error" => "Not Found" }, status: 404)
    assert_raises(Pagecord::NotFoundError) { @client.posts.get("missing") }
  end

  def test_raises_rate_limit_error_on_429
    stub_api(:get, "/posts", {}, status: 429)
    assert_raises(Pagecord::RateLimitError) { @client.posts.list }
  end

  def test_raises_validation_error_on_422
    stub_api(:post, "/home_page", { "error" => "Home page already exists" }, status: 422)
    assert_raises(Pagecord::ValidationError) { @client.home_page.set(title: "Duplicate") }
  end
end
