# twenv.rb

**Table of contents**

* [Introduction](#introduction)
* [Installation](#installation)
* [Commands](#commands)
  * [write-tweet](#commands-write-a-tweet)
  * [archive-timeline](#commands-archive-a-timeline)
  * [archive-likes](#commands-archive-likes)
  * [delete-my-tweets](#commands-delete-your-tweets)
  * [delete-my-likes](#commands-delete-your-likes)
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

**<a id='commands-write-a-tweet'> 1) write-tweet</a>**

You could write a tweet with the following Ruby code:

    [1] pry(#<TWEnv>)> client.update "I'm tweeting from twenv.rb"

Alternatively, you could use a command that's part of twenv.rb. It will open an
editor and after you exit post your tweet. By default the `nano` editor is used,
this can be changed in the `.env` file by setting `$EDITOR`.

    [1] pry(#<TWEnv>)> write-tweet

__<a id='commands-archive-a-timeline'> 2) archive-timeline</a>__

The `archive-timeline` command lets you archive a user's timeline of tweets. Like
other twenv.rb commands, this command sleeps and resumes when rate limited by
Twitter.

`archive-timeline` supports filtering what and how many tweets to archive, run
`archive-timeline --help` to see what options are available. By default all tweets
on a users timeline are archived, unless the `--max` option is passed or
an interrupt is received(`^C`) while the command runs.

The following is an example that archives recent retweets from [@banisterfiend](https://twitter.com/banisterfiend),
the creator of [Pry](https://github.com/pry/pry):

    [1] pry(#<TWEnv>)> archive-timeline banisterfiend --max 10 --is-retweet
    10 tweets archived
    Archive saved to /twenv.rb/storage/archive-timeline/banisterfiend.json
    Archive assigned to local variable `archived_timeline`
    [2] pry(#<TWEnv>)> archived_timeline.size
    => 10

It's possible to continue from where the `archive-timeline` command last stopped with
the `--continue` option:

    [3] pry(#<TWEnv>)> archive-timeline banisterfiend --max 10 --is-retweet --continue
    Continue from https://twitter.com/banisterfiend/status/1284254845504036870 (2020-07-17T22:33:10Z)
    10 tweets archived
    Archive saved to /twenv.rb/storage/archive-timeline/banisterfiend.json
    Archive assigned to local variable `archived_timeline`
    [4] pry(#<TWEnv>)> archived_timeline.size
    => 20

__<a id='commands-archive-likes'> 3) archive-likes</a>__

The `archive-likes` command lets you archive a user's likes. Like other twenv.rb
commands, this command sleeps and resumes when rate limited by Twitter.

`archive-likes` supports filtering what and how many likes to archive, run
`archive-likes --help` to see what options are available. By default all likes
belonging to a user are archived, unless the `--max` option is passed or an
interrupt is received(`^C`) while the command runs.

The following example archives the likes of [@yukihiro_matz](https://twitter.com/yukihiro_matz),
Ruby's creator, who had 17 likes at time of writing:

    [1] pry(#<TWEnv>)> archive-likes yukihiro_matz -m 10
    10 likes archived
    Archive saved to /twenv.rb/storage/archive-likes/yukihiro_matz.json
    Archive assigned to local variable `archived_likes`
    [2] pry(#<TWEnv>)> archived_likes.size
    => 10

It's possible to continue from where the `archive-likes` command last stopped with
the `--continue` option:

    [3] pry(#<TWEnv>)> archive-likes yukihiro_matz -m 10 --continue
    Continue from https://twitter.com/tsuchinao83/status/1107267964821106688 (2019-03-17T13:10:29Z)
    7 likes archived
    Archive saved to /twenv.rb/storage/archive-likes/yukihiro_matz.json
    Archive assigned to local variable `archived_likes`
    [4] pry(#<TWEnv>)> archived_likes.size
    17

 __<a id='commands-delete-your-tweets'> 4) delete-my-tweets</a>__

 The `delete-my-tweets` command can delete all your tweets, or a subset
 of them gathered by filtering. This command reads  your entire timeline; if
 there's a lot of tweets it might take a while. What follows are examples that
 demonstrate deleting all your tweets or just a subset of them:

    # Delete all tweets
    [1] pry(#<TWEnv>)> delete-my-tweets

    # Only delete tweets that are replies
    [1] pry(#<TWEnv>)> delete-my-tweets --is-reply

    # Only delete tweets that are replies with no likes
    [1] pry(#<TWEnv>)> delete-my-tweets --is-reply --has-no-likes

    # Show help
    [1] pry(#<TWEnv>)> delete-my-tweets --help

__<a id='commands-delete-your-likes'> 5) delete-my-likes</a>__

The `delete-my-likes` command deletes all your likes, or subset of them gathered
by filtering . Run `delete-my-likes --help` to discover what options are
available. The following example demonstrates a few different scenarios:

    # Delete all your likes
    [1] pry(#<TWEnv>)> delete-my-likes

    # Delete all your likes that are replies
    [1] pry(#<TWEnv>)> delete-my-likes --is-reply

    # Delete all your likes that are replies to a given username.
    [1] pry(#<TWEnv>)> delete-my-likes --is-reply-to=username

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
