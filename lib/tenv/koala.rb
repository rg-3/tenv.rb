class Tenv::Koala < Tenv::Command
  match 'koala'
  description 'Delivers a random tweet by koala'

  def process
    tweet = twitter_client.home_timeline(tweet_mode: 'extended').sample
    str = Cowsay.say "#{tweet.full_text} - #{bold('@'+tweet.user.screen_name)}", 'koala'
    puts str
  end
end
