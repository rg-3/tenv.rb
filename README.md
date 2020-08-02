# <a id='top'>twenv.rb</a>

**<a id='toc'>Table of contents</a>**

* [Introduction](#introduction)
* [Installation](#install)
  * [Clone repository](#install-clone)
  * [Setup .env file](#install-env)
  * [Install dependencies](#install-deps)
  * [Start twenv.rb](#install-start-twenv.rb)
* [The "client" local](#the-client-local)
* [Built-in Commands](#commands)
  * [write-tweet](#commands-write-a-tweet)
  * [archive-timeline](#commands-archive-a-timeline)
  * [archive-likes](#commands-archive-likes)
  * [read-links](#commands-read-links)
  * [delete-my-tweets](#commands-delete-your-tweets)
  * [delete-my-likes](#commands-delete-your-likes)
* [Customization](#custom)
  * [Write your own commands](#custom-write-your-own-commands)
* [License](#license)

## <a id='introduction'> Introduction </a>


twenv.rb provides a Twitter environment where you can interact with Twitter
through its web APIs using a REPL. The environment uses the [Ruby](https://www.ruby-lang.org) programming language,
[Pry](https://github.com/pry/pry#top) and the [Twitter library](https://github.com/sferik/twitter).

twenv.rb is a useful environment for learning, not only about Twitter, but
also about Ruby and Pry. Pry allows a high degree of customization and twenv.rb
follows that path as well.


[Back to top](#top)

## <a id='install'> Installation </a>

**<a id='install-clone'> 1) Clone repository </a>**

To get started clone a copy of the twenv.rb repository.
The installation method for this project is to clone a copy of twenv.rb and
then adopt it as your own environment.

    # Clone and change directory
    git clone https://github.com/rg-3/twenv.rb
    cd twenv.rb

    # Fork a branch from the latest version of twenv.rb.
    git fetch --tags
    git checkout tags/v0.6.0 -b my-twenv.rb


**2) <a id='install-env'>Setup .env file</a>**

For the next step, you should copy the sample `.env` file and then update it to
have the correct consumer keys and access tokens for your Twitter user. If you
are unfamiliar or don't have access to these yet, head over to https://developer.twitter.com.

	cp .env.sample .env


**3) <a id='install-deps'>Install dependencies</a>**

To install the dependencies, run the following from the root of the twenv.rb repository:

	gem install -g gem.deps.rb


**4) <a id='install-start-twenv.rb'>Start twenv.rb</a>**

From the twenv.rb root:

	bin/twenv.rb

[Back to top](#top)

## <a id='the-client-local'>The "client" local</a>

Once twenv.rb starts you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs. I recommend checking out the [documentation for the Twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

[Back to top](#top)

## <a id='commands'> Built-in Commands </a>

**<a id='commands-write-a-tweet'> 1) write-tweet</a>**

You could write a tweet with the following Ruby code:

    [1] twenv.rb (main)> client.update "I'm tweeting from twenv.rb"

Alternatively, you could use a command that's part of twenv.rb. It will open an
editor and after you exit post your tweet. By default the `nano` editor is used,
this can be changed in the `.env` file by setting `$EDITOR`.

    [1] twenv.rb (main)> write-tweet

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

    [1] twenv.rb (main)> archive-timeline banisterfiend --max 10 --is-retweet
    OK 10 tweets archived
    OK Archive saved to storage/archive-timeline/banisterfiend.json
    OK Archive assigned to local variable `archived_timeline`
    [2] twenv.rb (main)> archived_timeline.size
    => 10

It's possible to continue from where the `archive-timeline` command last stopped with
the `--continue` option:

    [3] twenv.rb (main)> archive-timeline banisterfiend --max 10 --is-retweet --continue
    OK Continue from https://twitter.com/banisterfiend/status/1284254845504036870 (2020-07-17T22:33:10Z)
    OK 10 tweets archived
    OK Archive saved to storage/archive-timeline/banisterfiend.json
    OK Archive assigned to local variable `archived_timeline`
    [4] twenv.rb (main)> archived_timeline.size
    => 20

__<a id='commands-archive-likes'> 3) archive-likes</a>__

The `archive-likes` command lets you archive a user's likes. Like other twenv.rb
commands, this command sleeps and resumes when rate limited by Twitter.

`archive-likes` supports filtering what and how many likes to archive, run
`archive-likes --help` to see what options are available. By default all likes
belonging to a user are archived, unless the `--max` option is passed or an
interrupt is received(`^C`) while the command runs.

The following example archives the 10 most recent likes from
[@yukihiro_matz](https://twitter.com/yukihiro_matz), Ruby's creator,
who had 17 likes at time of writing:

    [1] twenv.rb (main)> archive-likes yukihiro_matz -m 10
    OK 10 likes archived
    OK Archive saved to storage/archive-likes/yukihiro_matz.json
    OK Archive assigned to local variable `archived_likes`
    [2] twenv.rb (main)> archived_likes.size
    => 10

It's possible to continue from where the `archive-likes` command last stopped with
the `--continue` option:

    [3] twenv.rb (main)> archive-likes yukihiro_matz -m 10 --continue
    OK Continue from https://twitter.com/tsuchinao83/status/1107267964821106688 (2019-03-17T13:10:29Z)
    OK 7 likes archived
    OK Archive saved to storage/archive-likes/yukihiro_matz.json
    OK Archive assigned to local variable `archived_likes`
    [4] twenv.rb (main)> archived_likes.size
    17

__4) <a id='commands-read-links'>read-links</a>__

The `read-links` command lets you page through the external links being
shared on your home timeline or the timeline of a user. The hope is that
this command can reduce noise and enable you to discover new content to read
instead of idling on Twitter. There's a [demo video](https://asciinema.org/a/oD6nZ0830FVeQ7X10uUAHCa3Z)
to watch for this command.

The following example demonstrates the help menu:

    [1] twenv.rb (main)> read-links --help
    read-links [OPTIONS] [user]

    Read tweets that include external links

    Examples

    # Read links from the timeline of `client.user`
    twenv.rb (main)> read-links

    # Read links from @rubyinside
    twenv.rb (main)> read-links rubyinside --max 75

    Options

        -m, --max       The max number of links to find. Default is 25
        -h, --help      Show this message.


__<a id='commands-delete-your-tweets'> 5) delete-my-tweets</a>__

The `delete-my-tweets` command can delete all your tweets, or a subset
of them gathered by filtering. This command reads  your entire timeline; if
there's a lot of tweets it might take a while. What follows are examples that
demonstrate deleting all your tweets or just a subset of them:

    # Delete all tweets
    [1] twenv.rb (main)> delete-my-tweets

    # Only delete tweets that are replies
    [1] twenv.rb (main)> delete-my-tweets --is-reply

    # Only delete tweets that are replies with no likes
    [1] twenv.rb (main)> delete-my-tweets --is-reply --has-no-likes

    # Show help
    [1] twenv.rb (main)> delete-my-tweets --help

__<a id='commands-delete-your-likes'> 6) delete-my-likes</a>__

The `delete-my-likes` command deletes all your likes, or subset of them gathered
by filtering . Run `delete-my-likes --help` to discover what options are
available. The following example demonstrates a few different scenarios:

    # Delete all your likes
    [1] twenv.rb (main)> delete-my-likes

    # Delete all your likes that are replies
    [1] twenv.rb (main)> delete-my-likes --is-reply

    # Delete all your likes that are replies to a given username.
    [1] twenv.rb (main)> delete-my-likes --is-reply-to=username

[Back to top](#top)

## <a id='custom'>Customization</a>

**1) <a id='custom-write-your-own-commands'>Write your own commands</a>**

The `scripts/` directory is a place where you can add Ruby scripts that will be
loaded when twenv.rb starts. It's intended as a place you can add your own
commands and scripts that can be kept outside version control.

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

[Back to top](#top)


## <a id='license'>License</a>

MIT, see [./LICENSE.txt](./LICENSE.txt) for details.

[Back to top](#top)
