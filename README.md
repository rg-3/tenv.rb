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
  * [Writing tweets](#commands-write-a-tweet)
  * [delete-my-tweets](#commands-delete-your-tweets)
  * [delete-my-likes](#commands-delete-your-likes)
* [Customization](#custom)
  * [Write your own commands](#custom-write-your-own-commands)
  * [Customize the user-agent header](#custom-customize-the-user-agent-header)
* [License](#license)

## <a id='introduction'> Introduction </a>


twenv.rb provides a Twitter environment where you can interact with Twitter
through its web APIs using a REPL. The environment uses the [Ruby](https://www.ruby-lang.org) programming language,
[Pry](https://github.com/pry/pry#top) and the [Twitter library](https://github.com/sferik/twitter).

[Back to top](#top)

## <a id='install'> Installation </a>

**<a id='install-clone'> 1. Clone repository </a>**

To get started clone a copy of the twenv.rb repository.
The installation method for this project is to clone a copy of twenv.rb and
then adopt it as your own environment.

    # Clone and change directory
    git clone https://github.com/rg-3/twenv.rb
    cd twenv.rb

    # Fork a branch from the latest version of twenv.rb.
    git fetch --tags
    git checkout tags/v0.9.0 -b my-twenv.rb


**2. <a id='install-env'>Setup .env file</a>**

For the next step, you should copy the sample `.env` file and then update it to
have the correct consumer keys and access tokens for your Twitter account. If you
are unfamiliar or don't have access to these yet, head over to https://developer.twitter.com.

	cp .env.sample .env


**3. <a id='install-deps'>Install dependencies</a>**

To install the dependencies, run the following from the root of the twenv.rb repository:

	gem install -g gem.deps.rb


**4. <a id='install-start-twenv.rb'>Start twenv.rb</a>**

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

This section is for getting a taste of twenv.rb - it is not a comphrensive overview
but something to get you started.

**<a id='commands-write-a-tweet'> 1. Writing tweets </a>**

**1.1 client.update**

You could write a tweet with the following Ruby code:

    [1] twenv.rb (main)> client.update "I'm tweeting from twenv.rb"

**1.2 write-tweet command**

Or you could use the `write-tweet` command. The `write-tweet` command can
open an editor and after you exit post your tweet. By default the `nano`
editor is used. This can be changed from the `.env` file by setting `EDITOR`.

    [1] twenv.rb (main)> write-tweet

**1.3 write-tweet --files --delay**

The `write-tweet` command also supports delayed tweets via the `--delay` option.
Images and videos can be attached to a tweet with the `--files` option. For example,
to delay a tweet by 15 minutes and attach two photos:

    [1] twenv.rb (main)> write-tweet --delay #{60*15} --files ~/Pictures/photo1.jpg,~/Pictures/photo2.jpg

**1.4 write-tweet --tweet-file**

Another notable feature of the `write-tweet` command is the `--tweet-file=` option.
It is used to read a file from disk, run it through ERB and then use the result as
the tweets' content. For example:

    [1] twenv.rb (main)> write-tweet --tweet-file ~/erbtweets/systemtime.erb

Where the contents of `~/erbtweets/systemtime.erb` could be:

```erb
It is now <%= Time.now %>
```

Check out `write-tweet --help` for a complete overview of what this command can do.

__<a id='commands-delete-your-tweets'> 2. delete-my-tweets</a>__

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

__<a id='commands-delete-your-likes'> 3. delete-my-likes</a>__

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

**1. <a id='custom-write-your-own-commands'>Write your own commands</a>**

The `scripts/` directory is a place where you can add Ruby scripts that will be
loaded when twenv.rb starts. It's intended as a place you can add your own
commands and scripts that can be kept outside version control.

The [twenv.rb command class](https://github.com/rg-3/tenv.rb/blob/master/lib/twenv/command.rb)
inherits from the Pry command class and implements useful methods such as `client`. The following
is an example of a twenv.rb command:

```ruby
class RandomTweet < TWEnv::Command
  match 'random-tweet'
  description 'A random tweet from the home timeline of `client.user`'

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

**2. <a id='custom-customize-the-user-agent-header'>Customize the user-agent header</a>**

By default the user-agent header is sent as "twenv.rb vX.X.X".
This can be changed at runtime by setting `client.user_agent`.

For example:

    [1] twenv.rb (main)> client.user_agent = "my-user-agent"
    => "my-user-agent"

If you would like to change it to something else permanently you
can edit the `TWEnv.user_agent` method in [/lib/twenv.rb](https://github.com/rg-3/twenv.rb/blob/master/lib/twenv.rb).

[Back to top](#top)


## <a id='license'>License</a>

MIT, see [./LICENSE.txt](./LICENSE.txt) for details.

[Back to top](#top)
