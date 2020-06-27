class TWEnv::Command < Pry::ClassCommand
  require 'word_wrap'

  def self.add_command(command)
    Pry.commands.add_command command
  end

  def word_wrap(str, cols: 80, fit: true)
    WordWrap.ww str, cols, fit
  end

  def client
    pry_instance.config.extra_sticky_locals[:client]
  end

  def user_timeline(user, options)
    options.delete(:max_id) unless options[:max_id]
    client.user_timeline(user, options)
  end

  def perform_action_on_tweets(read_tweets, perform_action, total_recver, ids = [])
    catch(:cancel) do
      tweets = read_tweets.call
      if tweets.empty?
        total_recver.call(ids.size)
        throw(:cancel)
      end
      until tweets.empty?
        tweets.each do |tweet|
          next if ids.include?(tweet.id)
          ids.push(tweet.id)
          perform_action.call(tweet)
          total_recver.call(ids.size)
        end
        tweets = read_tweets.call
      end
    end
    line.end_line
  rescue Twitter::Error::TooManyRequests => e
    line.print "Rate limited. Retrying in #{e.retry_after} seconds"
    sleep e.retry_after
    perform_action_on_tweets(read_tweets, perform_action, total_recver, ids)
  end

  def line
    @line ||= TWEnv::Line.new(pry_instance.output)
  end
end
