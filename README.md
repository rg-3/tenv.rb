# twenv.rb

**Table of contents**

* [Introduction](#introduction)
* [Installation](#installation)
* [Commands](#commands)
  * [Write a tweet](#commands-write-a-tweet)
  * [Archive a timeline](#commands-archive-a-timeline)
  * [Archive liked tweets](#commands-archive-likes)
  * [Delete tweets](#commands-delete-your-tweets)
  * [Delete liked tweets](#commands-delete-your-likes)
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

__4. Start twenv.rb__

From the twenv.rb root:

	bin/twenv.rb

__5. Meet the "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the Twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

## <a id='commands'> Commands </a>

**<a id='commands-write-a-tweet'>Write a tweet</a>**

You could write a tweet with the following Ruby code:

    [1] pry(#<TWEnv>)> client.update "I'm tweeting from twenv.rb"

Alternatively, you could use a command that's part of twenv.rb. It will open an
editor and after you exit post your tweet. By default the `nano` editor is used,
this can be changed in the `.env` file by setting `$EDITOR`.

    [1] pry(#<TWEnv>)> write-tweet

__<a id='commands-archive-a-timeline'>Archive a timeline</a>__

The `archive-timeline` command lets you archive a user's timeline of tweets. This
command can be especially useful in enabling data analysis because it lets you
explore a timeline of tweets as an array of Hash objects. Like other twenv.rb commands,
this command sleeps and resumes when rate limited by Twitter. This command supports
filtering what tweets to archive, try `archive-timeline --help` to see what options
are available.

By default a timeline is saved as a JSON file.  
The following is an example that finds the most liked tweet in the last 500
tweets made by Yukihiro "Matz" Matsumoto:

	[1] pry(#<TWEnv>)> archive-timeline --max 500 yukihiro_matz
	500 tweets archived
	Archive saved to /twenv.rb/command_storage/archive-timeline/yukihiro_matz.json
	[2] pry(#<TWEnv>)> tweets = JSON.parse File.read('/twenv.rb/command_storage/archive-timeline/yukihiro_matz.json');
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

__<a id='commands-archive-likes'>Archive likes</a>__

The `archive-likes` command lets you archive tweets liked by a given user. This
command, like `archive-timeline`, can be especially useful in enabling data
analysis. Like other twenv.rb commands, this command sleeps and resumes when
rate limited by Twitter. In my experience, rate limiting occurs frequently on
this API, more so than other Twitter APIs I have tried.

`archive-likes` supports filtering what tweets to archive, try
`archive-likes --help` to see what options are available.

The following example archives the likes of Yukihiro "Matz" Matsumoto, who
happens to have a low number of liked tweets:

    [1] pry(#<TWEnv>)> archive-likes yukihiro_matz
    17 likes archived
    Archive saved to /twenv.rb/command_storage/archive-likes/yukihiro_matz.json


 __<a id='commands-delete-your-tweets'>Delete tweets</a>__

 The `delete-my-tweets` command can delete all your tweets, or a subset
 of your tweets gathered by filtering. It achieves this by reading your entire
 timeline; if there's a lot of tweets it might take a while. What follows are
 examples that demonstrate deleting all your tweets or just a subset of them:

 *A) Delete all tweets*

     [1] pry(#<TWEnv>)> delete-my-tweets

 *B) Delete replies*

     [1] pry(#<TWEnv>)> delete-my-tweets --replies-only

 *C) Delete replies with no likes*

     [1] pry(#<TWEnv>)> delete-my-tweets --replies-only --with-no-likes

 *D) Help and other options*

     [1] pry(#<TWEnv>)> delete-my-tweets --help

__<a id='commands-delete-your-likes'>Delete likes</a>__

The `delete-my-likes` command can delete all your likes, regardless
of how many :) It might just take a while if there's a lot, due to rate limiting.

    [2] pry(#<TWEnv>)> delete-my-likes

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
                  tweet: tweet.full_text,
                  author: bold("@#{tweet.user.screen_name}")
    puts out
  end

  add_command self
end
```
