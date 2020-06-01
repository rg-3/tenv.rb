class Tenv::Koala < Tenv::Command
  match 'koala'
  description 'A random tweet from your home timeline'

  def process
    tweet = twitter_client.home_timeline(tweet_mode: 'extended').sample
    out = format "%{tweet}\n- %{author}", tweet: word_wrap(tweet.full_text), author: bold("@#{tweet.user.screen_name}")
    puts out
  end
end
