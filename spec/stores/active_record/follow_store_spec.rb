require 'spec_helper'

describe Socialization::ActiveRecordStores::Creep do
  before do
    @klass = Socialization::ActiveRecordStores::Creep
    @klass.touch nil
    @klass.after_creep nil
    @klass.after_uncreep nil
    @creeper = ImACreeper.create
    @creepable = ImACreepable.create
  end

  describe "data store" do
    it "inherits Socialization::ActiveRecordStores::Creep" do
      expect(Socialization.creep_model).to eq(Socialization::ActiveRecordStores::Creep)
    end
  end

  describe "#creep!" do
    it "creates a Creep record" do
      @klass.creep!(@creeper, @creepable)
      expect(@creeper).to match_creeper(@klass.last)
      expect(@creepable).to match_creepable(@klass.last)
    end

    it "increments counter caches" do
      creeper   = ImACreeperWithCounterCache.create
      creepable = ImACreepableWithCounterCache.create
      @klass.creep!(creeper, creepable)
      expect(creeper.reload.creepees_count).to eq(1)
      expect(creepable.reload.creepers_count).to eq(1)
    end

    it "touches creeper when instructed" do
      @klass.touch :creeper
      expect(@creeper).to receive(:touch).once
      expect(@creepable).to receive(:touch).never
      @klass.creep!(@creeper, @creepable)
    end

    it "touches creepable when instructed" do
      @klass.touch :creepable
      expect(@creeper).to receive(:touch).never
      expect(@creepable).to receive(:touch).once
      @klass.creep!(@creeper, @creepable)
    end

    it "touches all when instructed" do
      @klass.touch :all
      expect(@creeper).to receive(:touch).once
      expect(@creepable).to receive(:touch).once
      @klass.creep!(@creeper, @creepable)
    end

    it "calls after creep hook" do
      @klass.after_creep :after_creep
      expect(@klass).to receive(:after_creep).once
      @klass.creep!(@creeper, @creepable)
    end

    it "calls after uncreep hook" do
      @klass.after_creep :after_uncreep
      expect(@klass).to receive(:after_uncreep).once
      @klass.creep!(@creeper, @creepable)
    end
  end

  describe "#uncreep!" do
    it "decrements counter caches" do
      creeper   = ImACreeperWithCounterCache.create
      creepable = ImACreepableWithCounterCache.create
      @klass.creep!(creeper, creepable)
      @klass.uncreep!(creeper, creepable)
      expect(creeper.reload.creepees_count).to eq(0)
      expect(creepable.reload.creepers_count).to eq(0)
    end
  end

  describe "#creeps?" do
    it "returns true when creep exists" do
      @klass.create! do |f|
        f.creeper = @creeper
        f.creepable = @creepable
      end
      expect(@klass.creeps?(@creeper, @creepable)).to be true
    end

    it "returns false when creep doesn't exist" do
      expect(@klass.creeps?(@creeper, @creepable)).to be false
    end
  end

  describe "#creepers" do
    it "returns an array of creepers" do
      creeper1 = ImACreeper.create
      creeper2 = ImACreeper.create
      creeper1.creep!(@creepable)
      creeper2.creep!(@creepable)
      expect(@klass.creepers(@creepable, creeper1.class)).to eq([creeper1, creeper2])
    end

    it "returns an array of creeper ids when plucking" do
      creeper1 = ImACreeper.create
      creeper2 = ImACreeper.create
      creeper1.creep!(@creepable)
      creeper2.creep!(@creepable)
      expect(@klass.creepers(@creepable, creeper1.class, :pluck => :id)).to eq([creeper1.id, creeper2.id])
    end
  end

  describe "#creepables" do
    it "returns an array of creepers" do
      creepable1 = ImACreepable.create
      creepable2 = ImACreepable.create
      @creeper.creep!(creepable1)
      @creeper.creep!(creepable2)
      expect(@klass.creepables(@creeper, creepable1.class)).to eq([creepable1, creepable2])
    end

    it "returns an array of creeper ids when plucking" do
      creepable1 = ImACreepable.create
      creepable2 = ImACreepable.create
      @creeper.creep!(creepable1)
      @creeper.creep!(creepable2)
      expect(@klass.creepables(@creeper, creepable1.class, :pluck => :id)).to eq([creepable1.id, creepable2.id])
    end
  end

  describe "#remove_creepers" do
    it "deletes all creepers relationships for a creepable" do
      @creeper.creep!(@creepable)
      expect(@creepable.creepers(@creeper.class).count).to eq(1)
      @klass.remove_creepers(@creepable)
      expect(@creepable.creepers(@creeper.class).count).to eq(0)
    end
  end

  describe "#remove_creepables" do
    it "deletes all creepables relationships for a creeper" do
      @creeper.creep!(@creepable)
      expect(@creeper.creepables(@creepable.class).count).to eq(1)
      @klass.remove_creepables(@creeper)
      expect(@creeper.creepables(@creepable.class).count).to eq(0)
    end
  end
end

