# CHANGELOG

## HEAD

* Add `TWEnv::Command::TwitterQuery`.

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
