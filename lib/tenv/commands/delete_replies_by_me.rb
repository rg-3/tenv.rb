class Tenv::DeleteRepliesByMe < Tenv::Command
  match "delete-replies-by-me"
  description "Delete recent replies made by you"
  banner "delete-replies-by-me"

  def process
    replies_by_me = proc do
      user = client.user
      client.user_timeline(user).select(&:reply?)
    end
    client.destroy_tweet(replies_by_me.()) until replies_by_me.().empty?
  end
end
