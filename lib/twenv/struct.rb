class TWEnv::Struct < OpenStruct
  #
  # @param [Hash] hash
  #   A hash object.
  #
  # @return [TWEnv::Struct]
  #   Recursively walks a Hash object and then returns an instance of
  #  {TWEnv::Struct} that encapsulates the Hash.
  #
  def self.from_hash(hash)
    result = {}
    hash.each do |k,v|
      case v
      when Array
        result[k] = v.map{|e| Array === e || Hash === e ? from_hash(e) : e}
      when Hash
        v.each {|k,v2| v[k] = Array === v2 || Hash === v2 ? from_hash(v2) : v2}
        result[k] = new(v)
      else
        result[k] = v
      end
    end
    new(result)
  end

  def initialize(*args)
    super(*args)
    @table.each_key do |k|
      # Define accessor methods early to allow the Pry `ls` command be able to
      # discover what getters this struct has.
      public_send(k)
    end
  end

  def to_json(options = {})
    @table.to_json(options)
  end
end
