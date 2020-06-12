class Tenv::RandomTweet < Tenv::Command
  match 'random-tweet'
  description 'A random tweet from your home timeline'

  def process
    tweet = client.home_timeline(tweet_mode: 'extended').sample
    out = format "%{tweet}- %{author}",
          tweet: word_wrap(tweet.full_text),
          author: bold("@#{tweet.user.screen_name}")
    puts out
  end
end
