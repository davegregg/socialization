module ActiveRecord
  class Base
    def is_creepable?
      false
    end
    alias creepable? is_creepable?
  end
end

module Socialization
  module Creepable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.creep_model.remove_creepers(self) }

      # Specifies if self can be creeped.
      #
      # @return [Boolean]
      def is_creepable?
        true
      end
      alias creepable? is_creepable?

      # Specifies if self is creeped by a {Creeper} object.
      #
      # @return [Boolean]
      def creeped_by?(creeper)
        raise Socialization::ArgumentError, "#{creeper} is not creeper!"  unless creeper.respond_to?(:is_creeper?) && creeper.is_creeper?
        Socialization.creep_model.creeps?(creeper, self)
      end

      # Returns an array of {Creeper}s creeping self.
      #
      # @param [Class] klass the {Creeper} class to be included. e.g. `User`
      # @return [Array<Creeper, Numeric>] An array of Creeper objects or IDs
      def creepers(klass, opts = {})
        Socialization.creep_model.creepers(self, klass, opts)
      end

      # Returns a scope of the {Creeper}s creeping self.
      #
      # @param [Class] klass the {Creeper} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def creepers_relation(klass, opts = {})
        Socialization.creep_model.creepers_relation(self, klass, opts)
      end
    end
  end
end