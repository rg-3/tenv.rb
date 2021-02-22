class Twitter::REST::Client
  #
  # @param [Array<Twitter::User, String>] *users
  #   A user to remove as a follower.
  #
  # @param [Integer] sleep
  #   The number of seconds to wait before removing
  #   the next follower. This option can be useful in
  #   avoiding the rate limit.
  #
  # @return [Array<Twitter::User, String>]
  #   Returns an array of users who were removed as
  #   followers.
  #
  def remove_follower!(*users, sleep: 0)
    users.map do |user|
      block(user)
      unblock(user)
      Kernel.sleep(sleep)
      user
    rescue
    end.compact
  end
end
