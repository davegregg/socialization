module Socialization
  module ActiveRecordStores
    class Creep < ActiveRecord::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Creep
      extend Socialization::ActiveRecordStores::Mixins::Base

      belongs_to :creeper,   :polymorphic => true
      belongs_to :creepable, :polymorphic => true

      scope :creeped_by, lambda { |creeper| where(
        :creeper_type   => creeper.class.table_name.classify,
        :creeper_id     => creeper.id)
      }

      scope :creeping,   lambda { |creepable| where(
        :creepable_type => creepable.class.table_name.classify,
        :creepable_id   => creepable.id)
      }

      class << self
        def creep!(creeper, creepable)
          unless creeps?(creeper, creepable)
            self.create! do |creep|
              creep.creeper = creeper
              creep.creepable = creepable
            end
            update_counter(creeper, creepees_count: +1)
            update_counter(creepable, creepers_count: +1)
            call_after_create_hooks(creeper, creepable)
            true
          else
            false
          end
        end

        def uncreep!(creeper, creepable)
          if creeps?(creeper, creepable)
            creep_for(creeper, creepable).destroy_all
            update_counter(creeper, creepees_count: -1)
            update_counter(creepable, creepers_count: -1)
            call_after_destroy_hooks(creeper, creepable)
            true
          else
            false
          end
        end

        def creeps?(creeper, creepable)
          !creep_for(creeper, creepable).empty?
        end

        # Returns an ActiveRecord::Relation of all the creepers of a certain type that are creeping creepable
        def creepers_relation(creepable, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:creeper_id).
              where(:creeper_type => klass.table_name.classify).
              where(:creepable_type => creepable.class.to_s).
              where(:creepable_id => creepable.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the creepers of a certain type that are creeping creepable
        def creepers(creepable, klass, opts = {})
          rel = creepers_relation(creepable, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Returns an ActiveRecord::Relation of all the creepables of a certain type that are creeped by creeper
        def creepables_relation(creeper, klass, opts = {})
          rel = klass.where(:id =>
            self.select(:creepable_id).
              where(:creepable_type => klass.table_name.classify).
              where(:creeper_type => creeper.class.to_s).
              where(:creeper_id => creeper.id)
          )

          if opts[:pluck]
            rel.pluck(opts[:pluck])
          else
            rel
          end
        end

        # Returns all the creepables of a certain type that are creeped by creeper
        def creepables(creeper, klass, opts = {})
          rel = creepables_relation(creeper, klass, opts)
          if rel.is_a?(ActiveRecord::Relation)
            rel.to_a
          else
            rel
          end
        end

        # Remove all the creepers for creepable
        def remove_creepers(creepable)
          self.where(:creepable_type => creepable.class.name.classify).
               where(:creepable_id => creepable.id).destroy_all
        end

        # Remove all the creepables for creeper
        def remove_creepables(creeper)
          self.where(:creeper_type => creeper.class.name.classify).
               where(:creeper_id => creeper.id).destroy_all
        end

      private
        def creep_for(creeper, creepable)
          creeped_by(creeper).creeping(creepable)
        end
      end # class << self

    end
  end
end
