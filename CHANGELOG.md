# CHANGELOG

## HEAD

* Disable shellwords in the `write-tweet` command.
 
* Show more information about scheduled tweets when using the 
  `--show-schedule` option of the `write-tweet` command.

* Add `--before-date=` option to the `delete-my-tweets` command.

* Perform a client-side verification on tweet size before attempting
  to send the tweet to Twitter. Tweets who exceed the maximum length
  can be edited until their size fits within Twitter's size constraint.

* Add `TWEnv::WriteTweet::ScheduledTweet` struct.

* Add `TWENV::Line#info`.

* Add `--delay-date`, `--cancel` options to the `write-tweet` command.

## v0.7.0

* Add the `--show-schedule` option to `write-tweet` command.

* Update the `delete-my-likes` `--no-replies` option to be `--is-not-reply`.

* Add `--is-not-reply` option to `delete-my-tweets`.

* Add `--in-reply-to=` option to the `write-tweet` command.

* Extend filters understood by the `delete-my-tweets` command to include 
  `--has-media`, `--no-media`, `--has-likes` and `--has-outbound-links`.

* Add `--is-reply-to=` filter option to the `delete-my-tweets` command.

* The `write-tweet` --delay option is parsed before you write a tweet 
  to catch errors early.

* The `write-tweet` --delay option now understands the 24hour clock, 
  in addition to the 12hour clock.

* The `write-tweet` --delay option now understands `X.hours` syntax.

* Implement strict option parsing within Pry. This means unknown 
  option switches will raise an error when passed to a twenv.rb
  command.  

* Monkey-patch `Pry::ClassCommand` to support receiving Slop options
  via `Pry::ClassCommand.slop_options`.

* Catch editor failure and report it as an error.

* Replace `DotEnv` module with a private class method on `TWEnv`.

* Rename `NoSuchArciveError` to `ArchiveNotFoundError`.

* Simplify `FormatTime` module.

* Add the `--files` option to `write-tweet`. The option allows you 
  to attach files(media) to a tweet.
  
* Expand `write-tweet --delay` to understand more duration syntax.

## v0.6.1

* Add bookmarking functionality to the `read-links` command.

* TWEnv::Line: avoid `String#capitalize` because it causes a
  mid-sentence "ALLCAPS" to be downcased.

* write-tweet: show publish time in human friendly format.

* Add `TWEnv::Command::FormatTime`.

* read-links: show tweet time in human friendly format.

* Update command descriptions.

* Change `read-links` max default from 10 tweets to 25.

* Improve `read-links -h`.

## v0.6.0

* Capitalize in the `Line#{ok,error,warn}` methods.

* Add `--delay` option to `write-tweet`.

* Add `TWEnv::Command#pager`.

* Rename `./commands` to `./scripts`.

* Add `--has-mentions`, `--no-mentions` to `archive-{timeline,likes}` commands.

* Add `--is-reply-to=` option to `archive-{timeline,likes}`.

* Add `Back to top` links to the README.

* Add `LICENSE.txt`.

## v0.5.0

* Log Interrupt errors to `Command#line`.

* Add `Line#{ok,warn,error}`.

* Rename `Line#end_line` to `Line#end`.

* Fix bug where `.env` variables were not initialized.

* Improve upon `archive-{timeline-likes}` to be aware of and handle more
  edge case scenarios.

## v0.4.1

* Start repl session in `TOPLEVEL_BINDING`.

* Update the prompt name to be `twenv.rb `.

* Update install instructions.

## v0.4.0

* Remove `TWENV_COMMAND_STORAGE_PATH` as a `.env` file variable.

* Update `archive-{timeline,likes}` to print paths that don't include
 `TWEnv.root_path`

* Add `TWEnv.root_path`.

* Add `Command#relative_to_root`.

* Add `--is-reply-to`, `--is-reply`, and `--no-replies` options to the
  `delete-my-likes` command.

* Return an array of `TWENV::Struct` objects from `read_archive`.

* Add `TWEnv::Struct`.

* Rename `write_file` to `write_archive`.

* Rename `parse_file` to `read_archive`.

* Rename command option `setup_storage` to just `storage`, eg
 `command_options storage: true`

* Add `-c`, `--continue` option to `archive-{timeline,likes}` commands.

* Add `TWEnv::Command#sticky_locals`.

* Add `TWEnv::Line#puts`.

* `archive-timeline` now assigns a local variable, `archived_timeline`, after
  the command completes to allow quick access to the archived timeline.

* `archive-likes` now assigns a local variable, `archived_likes`, after the
  command completes to allow quick access to the archived likes.

* Rename `command_storage_path` to just `storage_path`.

* Rename directory `command_storage/` to just `storage/`.

* Rename options across all commands.

* Add `TWEnv::Archiveable`.

* Add `video_urls` attribute in `format_tweet`.

* Add `--no-video`, `--only-video` options to `archive-timeline`.

* Create `command_storage_path` in `Command#setup` only when
`command_options[:setup_storage]` has been set to true.

## v0.3.1

* Fix NoMethodError when running `archive-{timeline,likes}` commands.

## v0.3.0

* Remove `--format` option from `archive-{likes,timeline}` commands.

* By default read all available tweets or likes in the `archive-{likes,timeline}`
  commands. The `--max` option can set the maximum number of tweets or likes
  to archive.

* Gracefully stop when `^C` is received while the `archive-{likes,timeline}`
  commands are running.

* Switch to a destructive backspace in `TWEnv::Line`.

* Add `is_reply` attribute in `format_tweet`.

* Add `--replies-only`, `--no-replies` options to `archive-timeline`.

* Remove `word_wrap` dependency and method.

* Add `archive-likes` command.

* Add `TWEnv::Command::FormatTweet`.

* Add `TWEnv::Command::TweetFilter`.

* Add `TWEnv::Command::FileHelper`.

* Add `TWEnv::Command::TwitterActions`.

* Add `TWEnv::Command::PerformActionOnTweets`.

## v0.2.0

* Fix error when falling through to `Twitter::Errors::TooManyRequests`.

* Re-imagine `TWEnv::Line` API.

* Update `write-tweet` to not try post when tweet content is empty.

* Update `TWEnv.start` to accept option Hashes that are forwarded to the
  Twitter library, and Pry.

* Rename `TWEnv.start_repl` as `TWEnv.start`.

* Update `.env.sample` to use `TWENV_*` instead of `TENV_*`.

* Rename `data/` directory to `command_storage/`.

* Decrease the default maximum number of tweets archived by the `archive-timeline`
  command from 500 to 50.

* Update messages written to stdout by the `delete-my-tweets` and
 `delete-my-likes` commands.

* Add `--[no|only]-retweets` options to the `archive-timeline` command.

* Add `--[no|only]-links` options to the `archive-timeline` command.

* Add `--[no|only]-media` options to the `archive-timeline` command.

* Add `--outbound-links-only` option to the `archive-timeline` command.

## v0.1.0

* First release
