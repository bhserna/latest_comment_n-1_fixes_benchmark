require "active_record"

ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "latest_comment_fixes")

# Uncomment if you want to see the logs
# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define(version: 1) do
  create_table :posts, if_not_exists: true do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :cached_comment_id, :integer
  end

  create_table :comments, if_not_exists: true do |t|
    t.column :body, :text
    t.column :post_id, :integer
  end
end
