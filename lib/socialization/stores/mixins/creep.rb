module Socialization
  module Stores
    module Mixins
      module Creep

      public
        def touch(what = nil)
          if what.nil?
            @touch || false
          else
            raise Socialization::ArgumentError unless [:all, :creeper, :creepable, false, nil].include?(what)
            @touch = what
          end
        end

        def after_creep(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_create_hook = method
        end

        def after_uncreep(method)
          raise Socialization::ArgumentError unless method.is_a?(Symbol) || method.nil?
          @after_destroy_hook = method
        end

      protected
        def call_after_create_hooks(creeper, creepable)
          self.send(@after_create_hook, creeper, creepable) if @after_create_hook
          touch_dependents(creeper, creepable)
        end

        def call_after_destroy_hooks(creeper, creepable)
          self.send(@after_destroy_hook, creeper, creepable) if @after_destroy_hook
          touch_dependents(creeper, creepable)
        end
      end
    end
  end
end
