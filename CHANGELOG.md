# CHANGELOG

## HEAD

* ...

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
