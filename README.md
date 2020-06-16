## Introduction

tenv.rb provides a Twitter environment where you can interact with Twitter
through its web APIs using a REPL. The environment uses the Ruby programming language,
the [Pry REPL](https://github.com/pry/pry#readme) and the [Twitter library](https://github.com/sferik/twitter).

## Manual

__1. Clone__

To get started clone a copy of the tenv.rb repository.
The installation method for this project is to clone a copy of tenv.rb and
then adopt it as your own environment.  

	git clone https://github.com/rg-3/tenv.rb
	cd tenv.rb

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

To start tenv.rb outside the working directory of the repository, you
could update your shell rc files to include the `bin/` directory:

	export PATH=$PATH:/path/to/tenv/repo/bin

__5. Start the repl__

If you updated the $PATH:

	tenv.rb

If you didn't, from the tenv root:

	bin/tenv.rb

__6. The "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

__7. Write a tweet__

You could write a tweet with the following Ruby code:

    client.update "I'm tweeting from tenv.rb"

Or, rely on a Pry command that's part of tenv. It will open an editor and
afterwards post your tweet:

    [1] pry(#<Tenv>)> write-tweet

__8. Delete your likes__

tenv.rb includes a builtin command that can delete all your likes, regardless
of how many :) It might just take a while if there's a lot, due to rate limiting.

		[2] pry(#<Tenv>)> delete-my-likes

__9. Delete your replies__

tenv.rb includes a builtin command that can delete all tweets that are replies
made by you. It does so by reading your whole timeline; if there's a lot of
tweets it might take a while.

		[3] pry(#<Tenv>)> delete-my-replies

__9. Write your own commands__

The `commands/` directory is a place where you can add Ruby scripts that will be
loaded when tenv.rb starts. It's intended as a place you can add your own commands
and scripts that can be kept outside version control.

The tenv.rb command class is a class who has inherited from the Pry command class.
It implements a `client` method that returns an instance of
`Twitter::REST::Client` and it acts as a super class for all tenv.rb commands.

The following is an example of a tenv.rb command:

```ruby
class RandomTweet < Tenv::Command
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
end
```
