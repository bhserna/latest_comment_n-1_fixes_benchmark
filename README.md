# Benchmark for the fixes to the latest-comment n+1 problem

What fix should you pick for your "latest-comment" n+1 queries problem?

I have shared [some fixes to help you solve the
problem](https://bhserna.com/5-ways-to-fix-the-latest-comment-n-1-problem.html) and some some
[benchmarks for this 5
fixes](https://bhserna.com/benchmarks-for-the-fixes-to-the-latest-comment-n-1-problem.html)...

This is the code that I use to run those benchmarks. You can use play with the
code and seed values, to make it more specific to your current problem.

## Benchmark structure

The benchmark will include the memory and the "iterations per second" benchmarks.

With this "reports"…

* `sorted_comments` - Default order for the "has many" association
* `latest_comment` - A "has one" association for the latest comment
* `feed looping` - Looping through the latest comment for each post
* `cached feed` - A version of the looping where we cache feed in memory
* `russian_doll` - Russian doll-caching (with a simpler cache mechanism)
* `cached_comment` - Caching the latest comment in a column


## How to run the benchmarks

1. **Create a postgres database** with `createdb latest_comment_fixes`. As
   you can see the in `db/config.rb` the name of the database is hardcoded, so
   you will need to create a database with that name.

2. **Install the dependencies** with `bundle install`.

3. **Run the benchmark** with `ruby lib/benchmark.rb`.

4. **Change the posts and comments count**  with `Seeds.run(posts_count: 10,
   comments_count: 10)`. You can change de count of post or comments per post,
   to test different scenarios.

5. **If you don't want to reset the seeds** comment `Seeds.run`, this will use
   the records from the last example run.
