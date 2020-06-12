class Tenv::WriteTweet < Tenv::Command
  match 'write-tweet'
  description "Write a tweet"

  def process
    unless ENV['EDITOR']
      raise Pry::CommandError, "Aborting because $EDITOR was not set."
    end
    file = Tempfile.new('tenv')
    system ENV['EDITOR'], file.path
    client.update(file.read)
  ensure
    file.unlink
    file.close
  end
end
