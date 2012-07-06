# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  default_scope order: 'microposts.created_at DESC'
  
  #check below comments but keep in mind that
  #even the subselect won’t scale forever
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end
  
  #? ensures that id is properly escaped before being included in the underlying SQL query,
  #thereby avoiding a serious security hole called SQL injection. 
  #Micropost.where("user_id = ?", id), the ? replaces the ? symbol for the variable (interpolation)
  #SQL: SELECT * FROM microposts WHERE user_id IN (<list of ids>) OR user_id = <user id>  
  #ruby code (Here we’ve used the Rails convention of user instead of user.id in the condition; 
  #Rails automatically uses the id. We’ve also omitted the leading Micropost): 
  #where("user_id in (?) OR user_id = ?", following_ids, user)
  #to get the ids array: User.first.followed_users.map(&:id)
  #here  [1, 2, 3, 4].map { |i| i.to_s } becomes [1, 2, 3, 4].map(&:to_s)
  #In fact, because this sort of construction is so useful, Active Record provides it by default 
  #based on the has_many :followed_users association:
  #User.first.followed_user_ids
  
  #THIS CODE HAS EFFICIENCY FLAWS
  #user.followed_user_ids would bring all followed user's ids into memory and then query again to
  #bring all required microposts. Is much better to perform the search for the ids in the DB and
  #bring only the microposts which is what we really want.
  # def self.from_users_followed_by(user)
    # followed_user_ids = user.followed_user_ids
    # where("user_id IN (?) OR user_id = ?", followed_user_ids, user)
  # end
end
