module Socialization
  module RedisStores
    class Creep < Socialization::RedisStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Creep
      extend Socialization::RedisStores::Mixins::Base

      class << self
        alias_method :creep!, :relation!;                          public :creep!
        alias_method :uncreep!, :unrelation!;                      public :uncreep!
        alias_method :creeps?, :relation?;                         public :creeps?
        alias_method :creepers_relation, :actors_relation;         public :creepers_relation
        alias_method :creepers, :actors;                           public :creepers
        alias_method :creepables_relation, :victims_relation;      public :creepables_relation
        alias_method :creepables, :victims;                        public :creepables
        alias_method :remove_creepers, :remove_actor_relations;    public :remove_creepers
        alias_method :remove_creepables, :remove_victim_relations; public :remove_creepables
      end

    end
  end
end
