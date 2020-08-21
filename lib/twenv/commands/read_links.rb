class TWEnv::ReadLinks < TWEnv::Command
  match 'read-links'
  description 'Read tweets that include external links'
  group 'twenv'
  command_options storage: true, argument_required: false
  banner <<-BANNER
  read-links [OPTIONS] [user]

  #{description}

  #{Paint['Examples', :bold]}

  #{Paint['# Read links from the home timeline of `client.user`', :underline]}
  twenv.rb (main)> read-links

  #{Paint['# Read links from @rubyinside', :underline]}
  twenv.rb (main)> read-links rubyinside --max 75

  #{Paint['Options', :bold]}
  BANNER

  MAX_WIDTH = 80

  attr_accessor :max_id, :user

  def options(slop)
    slop.on :m, :max=, "The max number of links to find. Default is 25.", as: :integer, default: 25
    slop.on :l, 'list-bookmarks'       , 'List saved bookmarks.'
    slop.on :s, 'save-bookmark='       , 'Bookmark an account to read another time.' , as: :string
    slop.on :b, 'bookmark='            , 'Read a bookmark by its index number.'      , as: :integer
    slop.on :d, 'delete-bookmark='     , 'Delete a bookmark by its index number.'    , as: :integer
  end

  def process(user=nil)
    case
    when opts['bookmark']
      read_bookmark(opts['bookmark'])
    when opts['save-bookmark']
      save_bookmark(opts['save-bookmark'].split(','))
    when opts['delete-bookmark']
      delete_bookmark(opts['delete-bookmark'])
    when opts['list-bookmarks']
      list_bookmarks
    else
      read_links(user)
    end
  end

  private

  def read_tweets
    read_and_filter method(:timeline_tweets),
                    method(:filter_tweets),
                    max_id
  end

  def timeline_tweets
    options = {tweet_mode: 'extended', max_id: max_id}
    if user
      user_timeline(user, options)
    else
      home_timeline(options)
    end
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    max_id = tweets[-1]&.id
    tweets.select! {|t| t.urls.any? { |url| url.expanded_url.host != 'twitter.com' } }
    tweets.tap{ self.max_id = max_id }
  end

  def print_total(total)
    line.rewind.ok("found #{total} tweets with external links")
    throw(:cancel) if total == max
  end

  def read_links(user)
    self.user = user
    tweets = []
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| tweets.push(tweet) },
                             method(:print_total)
    line.end
    show_tweets(tweets)
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
    show_tweets(tweets)
  end

  def show_tweets(tweets)
    out = [
      [Paint[user, :underline, "#FFF", "#000"]].join(" "),
      tweets.map do |tweet,index|
        content = tweet.text.each_line.to_a[0].strip
        tweet.urls.each{|url| content = content.gsub(url.url.to_s, '').gsub(/\s*[-:]\s*$/, '')}
        content = "#{content[0..MAX_WIDTH-1]}..." if content.size >= MAX_WIDTH
        [
          Paint[format_time(tweet.created_at, :upcase), :bold],
          content,
          tweet.urls.map {|url| url.expanded_url.to_s }.join("\n")
        ].join("\n")
      end.join("\n\n")
    ].join("\n\n")
    pager.page out
  end

  def save_bookmark(users)
    bookmarks.concat(users)
    File.write bookmarks_path, JSON.dump(bookmarks)
  end

  def delete_bookmark(index)
    raise Pry::CommandError, "No bookmark at that index was found" if bookmarks[index-1].nil?
    bookmarks[index-1] = nil
    File.write bookmarks_path, JSON.dump(bookmarks.compact)
  end

  def read_bookmark(index)
    bookmark = bookmarks[index-1]
    raise Pry::CommandError, "No bookmark by the index #{index} was found" unless bookmark
    read_links(bookmark)
  end

  def list_bookmarks
    pager.page [
      Paint["Bookmarks", :underline, "#FFF", "#000"],
      bookmarks.map.with_index(1) { |bookmark, index|
        "#{Paint["#{index}.", :bold, "#FFF", "#000"]} #{Paint[bookmark, "#FFF", "#000"]}"
      }.join("\n")
    ].join("\n")
  end

  def bookmarks
    @bookmarks ||= File.exist?(bookmarks_path) ? JSON.parse(File.read(bookmarks_path)) : []
  end

  def bookmarks_path
    File.join storage_path, 'bookmarks.json'
  end

  def max
    opts[:max]
  end

  add_command self
end
