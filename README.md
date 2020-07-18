# twenv.rb

**Table of contents**

* [Introduction](#introduction)
* [Installation](#installation)
* [Commands](#commands)
  * [Write a tweet](#commands-write-a-tweet)
  * [Archive tweets](#commands-archive-a-timeline)
  * [Archive likes](#commands-archive-likes)
  * [Delete tweets](#commands-delete-your-tweets)
  * [Delete likes](#commands-delete-your-likes)
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

__5. Introducing the "client" local__

Once twenv.rb starts you'll have access to a `client` local. It returns an instance
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

The `archive-timeline` command lets you archive a user's timeline of tweets. Like
other twenv.rb commands, this command sleeps and resumes when rate limited by
Twitter.

`archive-timeline` supports filtering what and how many tweets to archive, run
`archive-timeline --help` to see what options are available. By default all tweets
on a users timeline are archived, unless the `--max` option is passed or
an interrupt is received(`^C`) while the command runs.

The following is an example that finds the most liked tweet in the last 500
tweets made by Yukihiro "Matz" Matsumoto:

	[1] pry(#<TWEnv>)> archive-timeline --max 500 yukihiro_matz
	500 tweets archived
	Archive saved to /twenv.rb/command_storage/archive-timeline/yukihiro_matz.json
	[2] pry(#<TWEnv>)> tweets = JSON.parse File.read('/twenv.rb/command_storage/archive-timeline/yukihiro_matz.json');
	...
	[3] pry(#<TWEnv>)> most_liked_tweet = tweets.max_by{|t| t['like_count']}
	=> {...}

__<a id='commands-archive-likes'>Archive likes</a>__

The `archive-likes` command lets you archive tweets liked by a given user. Like
other twenv.rb commands, this command sleeps and resumes when rate limited by
Twitter. In my experience, rate limiting occurs frequently on this API, more so
than other Twitter APIs I have tried.

`archive-likes` supports filtering what and how many likes to archive, run
`archive-likes --help` to see what options are available. By default all likes
belonging to a user are archived, unless the `--max` option is passed or an
interrupt is received(`^C`) while the command runs.

The following example archives the likes of Yukihiro "Matz" Matsumoto, who
happens to have a low number of liked tweets:

    [1] pry(#<TWEnv>)> archive-likes yukihiro_matz
    17 likes archived
    Archive saved to /twenv.rb/command_storage/archive-likes/yukihiro_matz.json

 __<a id='commands-delete-your-tweets'>Delete tweets</a>__

 The `delete-my-tweets` command can delete all your tweets, or a subset
 of your tweets gathered by filtering. This command reads  your entire timeline; if
 there's a lot of tweets it might take a while. What follows are examples that
 demonstrate deleting all your tweets or just a subset of them:

    # Delete all tweets
    [1] pry(#<TWEnv>)> delete-my-tweets

    # Only delete tweets that are replies
    [1] pry(#<TWEnv>)> delete-my-tweets --replies-only

    # Only delete tweets that are replies with no likes
    [1] pry(#<TWEnv>)> delete-my-tweets --replies-only --with-no-likes

    # Show help
    [1] pry(#<TWEnv>)> delete-my-tweets --help

__<a id='commands-delete-your-likes'>Delete likes</a>__

The `delete-my-likes` command deletes all your likes.

    [1s] pry(#<TWEnv>)> delete-my-likes

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
