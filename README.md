## Introduction

tenv.rb provides a Twitter environment where you can interact with Twitter through
its web APIs from the comfort of an advanced REPL. It use technologies from the
Ruby programming language. The environment is composed of the [Pry repl](https://github.com/pry/pry)
and the [Twitter](https://github.com/sferik/twitter) library.

## Manual

__1. Clone__

To get started clone a copy of the tenv repository.
The installation method for this project is to clone a copy of tenv and
then adopt it as your own environment.  

	git clone https://github.com/rg-3/tenv.rb
	cd tenv.rb

__2. Set keys__

For the next step, you should copy the sample `.env` file and then update it to
have the correct consumer keys and access tokens for your Twitter user. If you
are unfamiliar or don't have access to these yet, head over to https://developer.twitter.com.

	cp .env.sample .env

__3. Bootstrap dependencies__

It's assumed you have a Ruby installation with RubyGems.

From here, you should install Bundler:

	gem install bundler --no-rdoc --no-ri

Then, bundle the dependencies to `.bundledgems`:

	bundle install --path .bundledgems

__3. Update $PATH (Optional)__

To start tenv outside the working directory of the repository, you
could update your shell rc files to include the `bin/` directory:

	export PATH=$PATH:/path/to/tenv/repo/bin

__4. Start the repl__

If you updated the $PATH:

	tenv.rb

If you didn't, from the tenv root:

	bin/tenv.rb

__5. The "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

__6. Write a tweet__

You could write a tweet with the following Ruby code:

    client.update "I'm tweeting from tenv.rb"

Or, rely on a Pry command that's part of tenv. It will open an editor and
afterwards post your tweet:

    write-tweet

__7. Write your own commands__

The `commands/` directory is a place where you can add Ruby scripts that will be
loaded when tenv starts. It's intended as a place you can add your own commands
and scripts.

The tenv command class is a class who has inherited from the Pry command class.
It implements a `twitter_client` method that returns an instance of
`Twitter::REST::Client` and it acts as a super class for all tenv commands.

The following example is a tenv command that prints a random tweet from your
timeline:

```ruby
class RandomTweet < Tenv::Command
  match 'random-tweet'
  description 'Randomly print the contents of a tweet'

  def process
    # Extended tweet mode provides access to the full tweet text rather
    # than a truncated version.
    tweets = twitter_client.home_timeline(tweet_mode: 'extended')
    puts bold(tweets.sample.full_text)
  end
end
```
