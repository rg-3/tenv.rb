class Tenv::RandomFav < Tenv::Command
  match 'random-fav'
  description 'A random favorite tweet'

  def process
    tweet = client.favorites(count: 200, tweet_mode: 'extended').sample
    out = format "%{tweet}- %{author}",
          tweet: word_wrap(tweet.full_text),
          author: bold("@#{tweet.user.screen_name}")
    puts out
  end
end
