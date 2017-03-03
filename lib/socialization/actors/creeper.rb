module ActiveRecord
  class Base
    def is_creeper?
      false
    end
    alias creeper? is_creeper?
  end
end

module Socialization
  module Creeper
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.creep_model.remove_creepables(self) }

      # Specifies if self can creep {Creepable} objects.
      #
      # @return [Boolean]
      def is_creeper?
        true
      end
      alias creeper? is_creeper?

      # Create a new {Creep creep} relationship.
      #
      # @param [Creepable] creepable the object to be creeped.
      # @return [Boolean]
      def creep!(creepable)
        raise Socialization::ArgumentError, "#{creepable} is not creepable!"  unless creepable.respond_to?(:is_creepable?) && creepable.is_creepable?
        Socialization.creep_model.creep!(self, creepable)
      end

      # Delete a {Creep creep} relationship.
      #
      # @param [Creepable] creepable the object to uncreep.
      # @return [Boolean]
      def uncreep!(creepable)
        raise Socialization::ArgumentError, "#{creepable} is not creepable!" unless creepable.respond_to?(:is_creepable?) && creepable.is_creepable?
        Socialization.creep_model.uncreep!(self, creepable)
      end

      # Toggles a {Creep creep} relationship.
      #
      # @param [Creepable] creepable the object to creep/uncreep.
      # @return [Boolean]
      def toggle_creep!(creepable)
        raise Socialization::ArgumentError, "#{creepable} is not creepable!" unless creepable.respond_to?(:is_creepable?) && creepable.is_creepable?
        if creeps?(creepable)
          uncreep!(creepable)
          false
        else
          creep!(creepable)
          true
        end
      end

      # Specifies if self creeps a {Creepable} object.
      #
      # @param [Creepable] creepable the {Creepable} object to test against.
      # @return [Boolean]
      def creeps?(creepable)
        raise Socialization::ArgumentError, "#{creepable} is not creepable!" unless creepable.respond_to?(:is_creepable?) && creepable.is_creepable?
        Socialization.creep_model.creeps?(self, creepable)
      end

      # Returns all the creepables of a certain type that are creeped by self
      #
      # @params [Creepable] klass the type of {Creepable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Creepable, Numeric>] An array of Creepable objects or IDs
      def creepables(klass, opts = {})
        Socialization.creep_model.creepables(self, klass, opts)
      end
      alias :creepees :creepables

      # Returns a relation for all the creepables of a certain type that are creeped by self
      #
      # @params [Creepable] klass the type of {Creepable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def creepables_relation(klass, opts = {})
        Socialization.creep_model.creepables_relation(self, klass, opts)
      end
      alias :creepees_relation :creepables_relation
    end
  end
end