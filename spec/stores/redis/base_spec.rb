require 'spec_helper'

describe Socialization::RedisStores::Base do
  # Testing through RedisStores::Creep for easy testing
  before(:each) do
    use_redis_store
    @klass = Socialization::RedisStores::Creep
    @klass.touch nil
    @klass.after_creep nil
    @klass.after_uncreep nil
    @creeper1 = ImACreeper.create
    @creeper2 = ImACreeper.create
    @creepable1 = ImACreepable.create
    @creepable2 = ImACreepable.create
  end

  describe "RedisStores::Base through RedisStores::Creep" do
    describe "Stores" do
      it "inherits Socialization::RedisStores::Creep" do
        expect(Socialization.creep_model).to eq(Socialization::RedisStores::Creep)
      end
    end

    describe "#creep!" do
      it "creates creep records" do
        @klass.creep!(@creeper1, @creepable1)
        expect(Socialization.redis.smembers(forward_key(@creepable1))).to match_array ["#{@creeper1.class}:#{@creeper1.id}"]
        expect(Socialization.redis.smembers(backward_key(@creeper1))).to match_array ["#{@creepable1.class}:#{@creepable1.id}"]

        @klass.creep!(@creeper2, @creepable1)
        expect(Socialization.redis.smembers(forward_key(@creepable1))).to match_array ["#{@creeper1.class}:#{@creeper1.id}", "#{@creeper2.class}:#{@creeper2.id}"]
        expect(Socialization.redis.smembers(backward_key(@creeper1))).to match_array ["#{@creepable1.class}:#{@creepable1.id}"]
        expect(Socialization.redis.smembers(backward_key(@creeper2))).to match_array ["#{@creepable1.class}:#{@creepable1.id}"]
      end

      it "touches creeper when instructed" do
        @klass.touch :creeper
        expect(@creeper1).to receive(:touch).once
        expect(@creepable1).to receive(:touch).never
        @klass.creep!(@creeper1, @creepable1)
      end

      it "touches creepable when instructed" do
        @klass.touch :creepable
        expect(@creeper1).to receive(:touch).never
        expect(@creepable1).to receive(:touch).once
        @klass.creep!(@creeper1, @creepable1)
      end

      it "touches all when instructed" do
        @klass.touch :all
        expect(@creeper1).to receive(:touch).once
        expect(@creepable1).to receive(:touch).once
        @klass.creep!(@creeper1, @creepable1)
      end

      it "calls after creep hook" do
        @klass.after_creep :after_creep
        expect(@klass).to receive(:after_creep).once
        @klass.creep!(@creeper1, @creepable1)
      end

      it "calls after uncreep hook" do
        @klass.after_creep :after_uncreep
        expect(@klass).to receive(:after_uncreep).once
        @klass.creep!(@creeper1, @creepable1)
      end
    end

    describe "#uncreep!" do
      before(:each) do
        @klass.creep!(@creeper1, @creepable1)
      end

      it "removes creep records" do
        @klass.uncreep!(@creeper1, @creepable1)
        expect(Socialization.redis.smembers(forward_key(@creepable1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@creeper1))).to be_empty
      end
    end

    describe "#creeps?" do
      it "returns true when creep exists" do
        @klass.creep!(@creeper1, @creepable1)
        expect(@klass.creeps?(@creeper1, @creepable1)).to be true
      end

      it "returns false when creep doesn't exist" do
        expect(@klass.creeps?(@creeper1, @creepable1)).to be false
      end
    end

    describe "#creepers" do
      it "returns an array of creepers" do
        creeper1 = ImACreeper.create
        creeper2 = ImACreeper.create
        creeper1.creep!(@creepable1)
        creeper2.creep!(@creepable1)
        expect(@klass.creepers(@creepable1, creeper1.class)).to match_array [creeper1, creeper2]
      end

      it "returns an array of creeper ids when plucking" do
        creeper1 = ImACreeper.create
        creeper2 = ImACreeper.create
        creeper1.creep!(@creepable1)
        creeper2.creep!(@creepable1)
        expect(@klass.creepers(@creepable1, creeper1.class, :pluck => :id)).to match_array ["#{creeper1.id}", "#{creeper2.id}"]
      end
    end

    describe "#creepables" do
      it "returns an array of creepables" do
        creepable1 = ImACreepable.create
        creepable2 = ImACreepable.create
        @creeper1.creep!(creepable1)
        @creeper1.creep!(creepable2)

        expect(@klass.creepables(@creeper1, creepable1.class)).to match_array [creepable1, creepable2]
      end

      it "returns an array of creepables ids when plucking" do
        creepable1 = ImACreepable.create
        creepable2 = ImACreepable.create
        @creeper1.creep!(creepable1)
        @creeper1.creep!(creepable2)
        expect(@klass.creepables(@creeper1, creepable1.class, :pluck => :id)).to match_array ["#{creepable1.id}", "#{creepable2.id}"]
      end
    end

    describe "#generate_forward_key" do
      it "returns valid key when passed an object" do
        expect(forward_key(@creepable1)).to eq("Creepers:#{@creepable1.class.name}:#{@creepable1.id}")
      end

      it "returns valid key when passed a String" do
        expect(forward_key("Creepable:1")).to eq("Creepers:Creepable:1")
      end
    end

    describe "#generate_backward_key" do
      it "returns valid key when passed an object" do
        expect(backward_key(@creeper1)).to eq("Creepables:#{@creeper1.class.name}:#{@creeper1.id}")
      end

      it "returns valid key when passed a String" do
        expect(backward_key("Creeper:1")).to eq("Creepables:Creeper:1")
      end
    end

    describe "#remove_creepers" do
      it "deletes all creepers relationships for a creepable" do
        @creeper1.creep!(@creepable1)
        @creeper2.creep!(@creepable1)
        expect(@creepable1.creepers(@creeper1.class).count).to eq(2)

        @klass.remove_creepers(@creepable1)
        expect(@creepable1.creepers(@creeper1.class).count).to eq(0)
        expect(Socialization.redis.smembers(forward_key(@creepable1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@creeper1))).to be_empty
        expect(Socialization.redis.smembers(backward_key(@creeper2))).to be_empty
      end
    end

    describe "#remove_creepables" do
      it "deletes all creepables relationships for a creeper" do
        @creeper1.creep!(@creepable1)
        @creeper1.creep!(@creepable2)
        expect(@creeper1.creepables(@creepable1.class).count).to eq(2)

        @klass.remove_creepables(@creeper1)
        expect(@creeper1.creepables(@creepable1.class).count).to eq(0)
        expect(Socialization.redis.smembers backward_key(@creepable1)).to be_empty
        expect(Socialization.redis.smembers backward_key(@creeper2)).to be_empty
        expect(Socialization.redis.smembers forward_key(@creeper1)).to be_empty
      end
    end

    describe "#key_type_to_type_names" do
      it "returns the proper arrays" do
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Creep)).to eq(['creeper', 'creepable'])
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Mention)).to eq(['mentioner', 'mentionable'])
        expect(@klass.send(:key_type_to_type_names, Socialization::RedisStores::Like)).to eq(['liker', 'likeable'])
      end
    end
  end

  # Helpers
  def forward_key(creepable)
    Socialization::RedisStores::Creep.send(:generate_forward_key, creepable)
  end

  def backward_key(creeper)
    Socialization::RedisStores::Creep.send(:generate_backward_key, creeper)
  end
end
