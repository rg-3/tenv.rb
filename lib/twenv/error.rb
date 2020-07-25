class TWEnv::Error < RuntimeError
  NoSuchArchiveError = Class.new(self)
end
