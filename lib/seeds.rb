module Seeds
  def self.run(config = {})
    seeds = SeedsRunner.new
    seeds.clear
    seeds.run(config)
  end

  class SeedsRunner
    def clear
      Post.delete_all
      Comment.delete_all
    end

    def run(config = {})
      seeds_data = SeedsData.new(config)
      posts = Post.create(seeds_data.posts_data)
      Comment.create(seeds_data.comments_data(posts))
    end
  end

  class SeedsData
    def initialize(config)
      @posts_count = config[:posts_count] || 10
      @comments_count = config[:comments_count] || 10
    end

    def posts_data
      (1..@posts_count).map { |i| {title: "p#{i}"} }
    end

    def post_comments_data(post)
      (1..@comments_count).map { |i| {post_id: post.id, body: "p#{post.id}-c#{i}"} }
    end

    def comments_data(posts)
      posts.flat_map { |post| post_comments_data(post) }
    end
  end
end
