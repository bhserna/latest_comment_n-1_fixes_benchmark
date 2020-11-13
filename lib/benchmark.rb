require_relative "../db/config"
require_relative "seeds"
require "benchmark"
require "benchmark/memory"
require "benchmark/ips"

class Post < ActiveRecord::Base
  has_many :comments
  has_many :sorted_comments, -> { order(:id) }, class_name: "Comment"
  has_one :latest_comment, -> { Comment.latest_comments_for_posts }, class_name: "Comment"
  belongs_to :cached_comment, class_name: "Comment"
end

class Comment < ActiveRecord::Base
  belongs_to :post
  after_commit :update_cached_comment

  def self.latest_comments_for_posts
    where(id: select("max(id)").group(:post_id))
  end

  private

  def update_cached_comment
    post.update(cached_comment_id: id)
  end
end

class Feed
  def posts
    @posts ||= fetch_posts
  end

  def fetch_posts
    posts = Post.all
    comments = Comment.latest_comments_for_posts.group_by(&:post_id)
    posts.map { |post| FeedPost.new(post, comments[post.id]&.first) }
  end
end

class FeedPost
  attr_reader :latest_comment

  def initialize(post, latest_comment)
    @post = post
    @latest_comment = latest_comment
  end
end

def cache(post)
  @cache ||= {}
  @cache[post.id] ||= yield
end

def clear_cache!
  @cache = {}
end

Seeds.run(posts_count: 20, comments_count: 100)

n = 1
puts ""
puts "Memory Benchmark"
puts "---------"

Benchmark.memory do |benchmark|
  benchmark.report("sorted_comments") do
    n.times do
      Post.includes(:sorted_comments).all.each do |post|
        post.sorted_comments.last.body
      end
    end
  end

  benchmark.report("latest_comment") do
    n.times do
      Post.includes(:latest_comment).all.each do |post|
        post.latest_comment.body
      end
    end
  end

  benchmark.report("feed looping") do
    n.times do
      Feed.new.posts.each do |post|
        post.latest_comment.body
      end
    end
  end

  feed = Feed.new
  benchmark.report("cached feed") do
    n.times do
      feed.posts.each do |post|
        post.latest_comment.body
      end
    end
  end

  benchmark.report("cached_comment") do
    n.times do
      Post.includes(:cached_comment).all.each do |post|
        post.cached_comment.body
      end
    end
  end

  benchmark.report("russian doll") do
    n.times do
      Post.all.each do |post|
        cache(post) do
          post.latest_comment.body
        end
      end
    end
  end

  clear_cache!
  benchmark.compare!
end


puts ""
puts "Benchmark ips"
puts "---------"


Benchmark.ips do |benchmark|
  benchmark.config(:time => 5, :warmup => 1)

  benchmark.report("sorted_comments") do
    Post.includes(:sorted_comments).all.each do |post|
      post.sorted_comments.last.body
    end
  end

  benchmark.report("latest_comment") do
    Post.includes(:latest_comment).all.each do |post|
      post.latest_comment.body
    end
  end

  benchmark.report("feed looping") do
    Feed.new.posts.each do |post|
      post.latest_comment.body
    end
  end

  feed = Feed.new
  benchmark.report("cached feed") do
    n.times do
      feed.posts.each do |post|
        post.latest_comment.body
      end
    end
  end

  benchmark.report("cached_comment") do
    Post.includes(:cached_comment).all.each do |post|
      post.cached_comment.body
    end
  end

  benchmark.report("russian doll") do
    Post.all.each do |post|
      cache(post) do
        post.latest_comment.body
      end
    end
  end

  benchmark.compare!
end
