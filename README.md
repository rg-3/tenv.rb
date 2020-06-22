# twenv.rb

**Table of contents**

* [Introduction](#introduction)
* [Installation](#installation)
* [Usage](#usage)

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

__3. Bootstrap dependencies__

It's assumed you have a Ruby installation with RubyGems.

From here, you should install Bundler:

	gem install bundler --no-rdoc --no-ri

Then, bundle the dependencies:

	bundle install

__4. Update $PATH (Optional)__

To start twenv.rb outside the working directory of the repository, you
could update your shell rc files to include the `bin/` directory:

	export PATH=$PATH:/path/to/twenv/repo/bin

__5. Start the repl__

If you updated the $PATH:

	twenv.rb

If you didn't, from the twenv root:

	bin/twenv.rb

__6. The "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

## <a id='usage'> Usage </a>

__Write a tweet__

You could write a tweet with the following Ruby code:

    [1] pry(#<TWEnv>)> client.update "I'm tweeting from twenv.rb"

Alternatively, you could use a command that's part of twenv.rb. It will open an editor and
afterwards post your tweet. By default the `nano` editor is used, this can
be changed in the `.env` file by setting `$EDITOR`.

    [1] pry(#<TWEnv>)> write-tweet

__Delete your likes__

twenv.rb includes a builtin command that can delete all your likes, regardless
of how many :) It might just take a while if there's a lot, due to rate limiting.

    [2] pry(#<TWEnv>)> delete-my-likes

__Delete your replies__

twenv.rb includes a builtin command that can delete all tweets that are replies
made by you. It does so by reading your whole timeline; if there's a lot of
tweets it might take a while.

    [3] pry(#<TWEnv>)> delete-my-replies

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
