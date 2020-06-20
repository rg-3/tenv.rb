# twenv.rb

**Table of contents**

* [Introduction](#introduction)
* [Installation](#installation)
* [Usage](#usage)
* [Customization](#custom)


## <a id='#introduction'> Introduction </a>

twenv.rb provides a Twitter environment where you can interact with Twitter
through its web APIs using a REPL. The environment uses the Ruby programming language,
[Pry](https://github.com/pry/pry#readme) and the [Twitter library](https://github.com/sferik/twitter).

## <a id='#installation'> Installation </a>

__1. Clone__

To get started clone a copy of the twenv.rb repository.
The installation method for this project is to clone a copy of twenv.rb and
then adopt it as your own environment.  

	git clone https://github.com/rg-3/twenv.rb
	cd twenv.rb

__2. Configure env__

For the next step, you should copy the sample `.env` file and then update it to
have the correct consumer keys and access tokens for your Twitter user. If you
are unfamiliar or don't have access to these yet, head over to https://developer.twitter.com.

	cp .env.sample .env

__3. Install dependencies__

To install the dependencies, run the following from the root of the twenv.rb repository:

	gem install -g gem.deps.rb

__4. Update $PATH (Optional)__

To start twenv.rb outside the working directory of the repository, you
could update your shell rc files to include the `bin/` directory:

	export PATH=$PATH:/path/to/twenv/repo/bin

__5. Start the repl__

If you updated the $PATH:

	twenv.rb

If you didn't, from the twenv.rb root:

	bin/twenv.rb

__6. The "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the Twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

## <a id='usage'> Usage </a>

__Write a tweet__

You could write a tweet with the following Ruby code:

    [1] pry(#<TWEnv>)> client.update "I'm tweeting from twenv.rb"

Alternatively, you could use a command that's part of twenv.rb. It will open an editor and
afterwards post your tweet. By default the `nano` editor is used, this can
be changed in the `.env` file by setting `$EDITOR`.

    [1] pry(#<TWEnv>)> write-tweet

__Archive a timeline__

The `archive-timeline` command lets you archive a user's timeline of tweets. This
command can be especially useful in enabling data analysis because it lets you
explore a timeline of tweets as an array of Hash objects. Like other twenv.rb commands,
this command sleeps and resumes when rate limited by Twitter.

By default a timeline is saved as a JSON file.  
The following is an example that saves the last 500 tweets made by Yukihiro "Matz" Matsumoto:

		[1] pry(#<TWEnv>)> archive-timeline -m 500 yukihiro_matz
		500 tweets archived
		Archive saved to /home/rg/twenv.rb/data/yukihiro_matz.json
		[2] pry(#<TWEnv>)> tweets = JSON.parse File.read('/home/rg/twenv.rb/data/yukihiro_matz.json');
		...
		[3] pry(#<TWEnv>)> most_liked_tweet = tweets.max_by{|t| t['like_count']}
		=> {"id"=>1251880011948158976,
         "url" => "https://twitter.com/yukihiro_matz/status/1251880011948158976",
		 "text"=>
		  "「動的型言語で地獄を見るぞ」って話はもういいから、「俺の推し言語はこんなに素晴らしいぞ」って話をしてほしい。\n「俺は地獄を見たぞ」って話はだいたい八つ当たりだから。\n「Rubyに滅んでほしい」と言わないで「俺言語の天国においで」とみんなを誘って結果的にRubyを滅ぼしてほしい。",
		 "is_retweet"=>false,
		 "retweet_count"=>828,
		 "like_count"=>2642,
		 "created_at"=>"2020-04-19T14:27:08Z",
		 "archived_at"=>"2020-07-04T22:13:17Z",
		 "urls"=>[],
		 "user_mentions"=>[],
		 "author"=>
		  {"id"=>20104013,
		   "name"=>"Yukihiro Matsumoto",
		   "screen_name"=>"yukihiro_matz",
		   "location"=>"島根県Matz江市",
		   "description"=>"Matzまたは、まつもとゆきひろ。Rubyのパパ。",
		   "verified"=>false,
		   "protected"=>false,
		   "followers_count"=>75660,
		   "listed_count"=>2926,
		   "tweet_count"=>32934,
		   "like_count"=>17}}


__Delete your likes__

twenv.rb includes a builtin command that can delete all your likes, regardless
of how many :) It might just take a while if there's a lot, due to rate limiting.

    [2] pry(#<TWEnv>)> delete-my-likes

__Delete your replies__

twenv.rb includes a builtin command that can delete all tweets that are replies
made by you. It does so by reading your whole timeline; if there's a lot of
tweets it might take a while.

    [3] pry(#<TWEnv>)> delete-my-replies

## <a id='custom'>Customization</a>

__Write your own commands__

The `commands/` directory is a place where you can add Ruby scripts that will be
loaded when twenv.rb starts. It's intended as a place you can add your own commands
and scripts that can be kept outside version control.

The [twenv.rb command class](https://github.com/rg-3/tenv.rb/blob/master/lib/twenv/command.rb)
inherits from the Pry command class and implements useful methods such as `client`. The following
is an example of a twenv.rb command:

```ruby
class RandomTweet < TWEnv::Command
  match 'random-tweet'
  description 'A random tweet from your home timeline'

  def process
    # Extended tweet mode provides access to the full tweet text rather
    # than a truncated version.
    tweet = client.home_timeline(tweet_mode: 'extended').sample
    out = format "%{tweet}\n- %{author}",
          tweet: word_wrap(tweet.full_text),
          author: bold("@#{tweet.user.screen_name}")
    puts out
  end

  add_command self
end
```
