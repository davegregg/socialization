module Socialization
  class << self
    def creep_model
      if @creep_model
        @creep_model
      else
        ::Creep
      end
    end

    def creep_model=(klass)
      @creep_model = klass
    end

    def like_model
      if @like_model
        @like_model
      else
        ::Like
      end
    end

    def like_model=(klass)
      @like_model = klass
    end

    def mention_model
      if @mention_model
        @mention_model
      else
        ::Mention
      end
    end

    def mention_model=(klass)
      @mention_model = klass
    end
  end
end