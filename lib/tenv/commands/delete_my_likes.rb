class Tenv::DeleteMyLikes < Tenv::Command
  match 'delete-my-likes'
  description 'Delete my likes'

  def process
    total ||= 0
    tweets = client.favorites
    until tweets.empty?
      tweets.each do |tweet|
        client.unfavorite(tweet)
        total += 1
        clear_line
        print "#{total} tweets unliked"
      end
      tweets = client.favorites
    end
    print "You have no likes to delete" if total == 0
    print "\n"
  rescue Twitter::Error::TooManyRequests => e
    clear_line
    print "Rate limited. Retrying in #{e.retry_after} seconds"
    sleep e.retry_after
    retry
  end
end
