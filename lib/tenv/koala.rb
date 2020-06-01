class Tenv::Koala < Tenv::Command
  match 'koala'
  description 'Delivers a random tweet by koala'

  def process
    tweet = random_timeline_tweet
    str = Cowsay.say "#{tweet.full_text} - #{bold('@'+tweet.user.screen_name)}", 'koala'
    puts str
  end
end
