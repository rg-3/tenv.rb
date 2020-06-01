## Introduction

twenv provides a Twitter environment where you can interact with Twitter through
its web APIs from the comfort of an advanced REPL. It use technologies from the
Ruby programming language. The environment is composed of the [Pry repl](https://github.com/pry/pry)
and the [Twitter](https://github.com/sferik/twitter) library.

## Manual

__1. Clone__

To get started clone a copy of the twenv repository.
The installation method for this project is to clone a copy of twenv and
then adopt it as your own environment.  

	git clone https://github.com/rg-3/twenv.rb
	cd twenv.rb

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

To start twenv outside the working directory of the repository, you
could update your shell rc files to include the `bin/` directory:

	export PATH=$PATH:/path/to/twenv/repo/bin

__4. Start the repl__

If you updated the $PATH:

	twenv

If you didn't, from the twenv root:

	bin/twenv

__5. The "client" local__

Once started, you'll have access to a `client` local. It returns an instance
of `Twitter::REST::Client`, from there you can play around with numerous
Twitter APIs.

I recommend checking out the
[documentation for the twitter library](https://www.rubydoc.info/gems/twitter)
to see what's possible.

__6. Write a tweet__

You could write a tweet with the following Ruby code:

    client.update "I'm tweeting from twenv"

Or, rely on a Pry command that's part of twenv. It will open your editor and
afterwards post your tweet:

    write-tweet
