class Pry::Command
  class << self
    def slop_options(options = nil)
      @slop_options = options if options
      @slop_options || {}
    end
  end
end

class Pry::ClassCommand < Pry::Command
  def self.inherited(klass)
    klass.match match
    klass.description description
    klass.command_options options
    klass.slop_options slop_options
  end

  def slop
    Pry::Slop.new(self.class.slop_options) do |opt|
      opt.banner(unindent(self.class.banner))
      subcommands(opt)
      options(opt)
      opt.on :h, :help, "Show this message."
    end
  end
end
