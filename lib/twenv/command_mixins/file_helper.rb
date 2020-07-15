module TWEnv::Command::FileHelper
  require 'json'

  def parse_file path, format
    case format.downcase.strip
    when "json" then JSON.parse File.read(path)
    end
  end

  def write_file path, tweets, format
    case format.downcase.strip
    when "json" then File.write path, JSON.dump(tweets)
    end
  end
end
