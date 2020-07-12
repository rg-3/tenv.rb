module TWEnv::Command::FileHelper
  def parse_file path, format
    case format.downcase.strip
    when "json" then JSON.parse File.read(path)
    when "yaml" then YAML.load File.read(path)
    end
  end

  def write_file path, tweets, format
    case format.downcase.strip
    when "json" then File.write path, JSON.dump(tweets)
    when "yaml" then File.write path, YAML.dump(tweets)
    end
  end
end
