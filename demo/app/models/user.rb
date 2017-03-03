class User < ActiveRecord::Base
  acts_as_creeper
  acts_as_creepable

  acts_as_liker
  acts_as_mentionable
end
