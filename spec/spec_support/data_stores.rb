require 'mock_redis' if $MOCK_REDIS
require 'redis' unless $MOCK_REDIS

silence_warnings do
  Redis = MockRedis if $MOCK_REDIS # Magic!
end

def use_redis_store
  Socialization.creep_model = Socialization::RedisStores::Creep
  Socialization.mention_model = Socialization::RedisStores::Mention
  Socialization.like_model = Socialization::RedisStores::Like
  setup_model_shortcuts
end

def use_ar_store
  Socialization.creep_model = Socialization::ActiveRecordStores::Creep
  Socialization.mention_model = Socialization::ActiveRecordStores::Mention
  Socialization.like_model = Socialization::ActiveRecordStores::Like
  setup_model_shortcuts
end

def setup_model_shortcuts
  $Creep = Socialization.creep_model
  $Mention = Socialization.mention_model
  $Like = Socialization.like_model
end

def clear_redis
  Socialization.redis.keys(nil).each do |k|
    Socialization.redis.del k
  end
end

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection(:sqlite3)

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end

  create_table :celebrities do |t|
    t.string :name
  end

  create_table :movies do |t|
    t.string :name
  end

  create_table :comments do |t|
    t.integer :user_id
    t.integer :movie_id
    t.string :body
  end

  create_table :creeps do |t|
    t.string  :creeper_type
    t.integer :creeper_id
    t.string  :creepable_type
    t.integer :creepable_id
    t.datetime :created_at
  end

  create_table :likes do |t|
    t.string  :liker_type
    t.integer :liker_id
    t.string  :likeable_type
    t.integer :likeable_id
    t.datetime :created_at
  end

  create_table :mentions do |t|
    t.string  :mentioner_type
    t.integer :mentioner_id
    t.string  :mentionable_type
    t.integer :mentionable_id
    t.datetime :created_at
  end

  create_table :im_a_creepers do |t|
    t.timestamps null: true
  end

  create_table :im_a_creeper_with_counter_caches do |t|
    t.integer :creepees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_creepables do |t|
    t.timestamps null: true
  end

  create_table :im_a_creepable_with_counter_caches do |t|
    t.integer :creepers_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_likers do |t|
    t.timestamps null: true
  end

  create_table :im_a_liker_with_counter_caches do |t|
    t.integer :likees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_likeables do |t|
    t.timestamps null: true
  end

  create_table :im_a_likeable_with_counter_caches do |t|
    t.integer :likers_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentioners do |t|
    t.timestamps null: true
  end

  create_table :im_a_mentioner_with_counter_caches do |t|
    t.integer :mentionees_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentionables do |t|
    t.timestamps null: true
  end

  create_table :im_a_mentionable_with_counter_caches do |t|
    t.integer :mentioners_count, default: 0
    t.timestamps null: true
  end

  create_table :im_a_mentioner_and_mentionables do |t|
    t.timestamps null: true
  end

  create_table :vanillas do |t|
    t.timestamps null: true
  end
end

class ::Celebrity < ActiveRecord::Base
  acts_as_creepable
  acts_as_mentionable
end

class ::User < ActiveRecord::Base
  acts_as_creeper
  acts_as_creepable
  acts_as_liker
  acts_as_likeable
  acts_as_mentionable

  has_many :comments
end

class ::Comment < ActiveRecord::Base
  acts_as_mentioner
  belongs_to :user
  belongs_to :movie
end

class ::Movie < ActiveRecord::Base
  acts_as_likeable
  has_many :comments
end

# class Creep < Socialization::ActiveRecordStores::Creep; end
# class Like < Socialization::ActiveRecordStores::Like; end
# class Mention < Socialization::ActiveRecordStores::Mention; end

class ::ImACreeper < ActiveRecord::Base
  acts_as_creeper
end
class ::ImACreeperWithCounterCache < ActiveRecord::Base
  acts_as_creeper
end
class ::ImACreeperChild < ImACreeper; end

class ::ImACreepable < ActiveRecord::Base
  acts_as_creepable
end
class ::ImACreepableWithCounterCache < ActiveRecord::Base
  acts_as_creepable
end
class ::ImACreepableChild < ImACreepable; end

class ::ImALiker < ActiveRecord::Base
  acts_as_liker
end
class ::ImALikerWithCounterCache < ActiveRecord::Base
  acts_as_liker
end
class ::ImALikerChild < ImALiker; end

class ::ImALikeable < ActiveRecord::Base
  acts_as_likeable
end
class ::ImALikeableWithCounterCache < ActiveRecord::Base
  acts_as_likeable
end
class ::ImALikeableChild < ImALikeable; end

class ::ImAMentioner < ActiveRecord::Base
  acts_as_mentioner
end
class ::ImAMentionerWithCounterCache < ActiveRecord::Base
  acts_as_mentioner
end
class ::ImAMentionerChild < ImAMentioner; end

class ::ImAMentionable < ActiveRecord::Base
  acts_as_mentionable
end
class ::ImAMentionableWithCounterCache < ActiveRecord::Base
  acts_as_mentionable
end
class ::ImAMentionableChild < ImAMentionable; end

class ::ImAMentionerAndMentionable < ActiveRecord::Base
  acts_as_mentioner
  acts_as_mentionable
end

class ::Vanilla < ActiveRecord::Base
end

