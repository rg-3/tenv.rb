class TWEnv::Error < RuntimeError
  ArchiveNotFoundError = Class.new(self)
end
