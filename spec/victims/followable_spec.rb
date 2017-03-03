require 'spec_helper'

describe Socialization::Creepable do
  before(:all) do
    use_ar_store
    @creeper = ImACreeper.new
    @creepable = ImACreepable.create
  end

  describe "#is_creepable?" do
    it "returns true" do
      expect(@creepable.is_creepable?).to be true
    end
  end

  describe "#creepable?" do
    it "returns true" do
      expect(@creepable.creepable?).to be true
    end
  end

  describe "#creeped_by?" do
    it "does not accept non-creepers" do
      expect { @creepable.creeped_by?(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Creep.creeps?" do
      expect($Creep).to receive(:creeps?).with(@creeper, @creepable).once
      @creepable.creeped_by?(@creeper)
    end
  end

  describe "#creepers" do
    it "calls $Creep.creepers" do
      expect($Creep).to receive(:creepers).with(@creepable, @creeper.class, { :foo => :bar })
      @creepable.creepers(@creeper.class, { :foo => :bar })
    end
  end

  describe "#creepers_relation" do
    it "calls $Creep.creepers_relation" do
      expect($Creep).to receive(:creepers_relation).with(@creepable, @creeper.class, { :foo => :bar })
      @creepable.creepers_relation(@creeper.class, { :foo => :bar })
    end
  end

  describe "deleting a creepable" do
    before(:all) do
      @creeper = ImACreeper.create
      @creeper.creep!(@creepable)
    end

    it "removes creep relationships" do
      expect(Socialization.creep_model).to receive(:remove_creepers).with(@creepable)
      @creepable.destroy
    end
  end
end

