require 'spec_helper'

describe Socialization::Creeper do
  before(:all) do
    use_ar_store
    @creeper = ImACreeper.new
    @creepable = ImACreepable.create
  end

  describe "#is_creeper?" do
    it "returns true" do
      expect(@creeper.is_creeper?).to be true
    end
  end

  describe "#creeper?" do
    it "returns true" do
      expect(@creeper.creeper?).to be true
    end
  end

  describe "#creep!" do
    it "does not accept non-creepables" do
      expect { @creeper.creep!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Creep.creep!" do
      expect($Creep).to receive(:creep!).with(@creeper, @creepable).once
      @creeper.creep!(@creepable)
    end
  end

  describe "#uncreep!" do
    it "does not accept non-creepables" do
      expect { @creeper.uncreep!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Creep.creep!" do
      expect($Creep).to receive(:uncreep!).with(@creeper, @creepable).once
      @creeper.uncreep!(@creepable)
    end
  end

  describe "#toggle_creep!" do
    it "does not accept non-creepables" do
      expect { @creeper.uncreep!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "uncreeps when creeping" do
      expect(@creeper).to receive(:creeps?).with(@creepable).once.and_return(true)
      expect(@creeper).to receive(:uncreep!).with(@creepable).once
      @creeper.toggle_creep!(@creepable)
    end

    it "creeps when not creeping" do
      expect(@creeper).to receive(:creeps?).with(@creepable).once.and_return(false)
      expect(@creeper).to receive(:creep!).with(@creepable).once
      @creeper.toggle_creep!(@creepable)
    end
  end

  describe "#creeps?" do
    it "does not accept non-creepables" do
      expect { @creeper.uncreep!(:foo) }.to raise_error(Socialization::ArgumentError)
    end

    it "calls $Creep.creeps?" do
      expect($Creep).to receive(:creeps?).with(@creeper, @creepable).once
      @creeper.creeps?(@creepable)
    end
  end

  describe "#creepables" do
    it "calls $Creep.creepables" do
      expect($Creep).to receive(:creepables).with(@creeper, @creepable.class, { :foo => :bar })
      @creeper.creepables(@creepable.class, { :foo => :bar })
    end
  end

  describe "#creepees" do
    it "calls $Creep.creepables" do
      expect($Creep).to receive(:creepables).with(@creeper, @creepable.class, { :foo => :bar })
      @creeper.creepees(@creepable.class, { :foo => :bar })
    end
  end

  describe "#creepables_relation" do
    it "calls $Creep.creepables_relation" do
      expect($Creep).to receive(:creepables_relation).with(@creeper, @creepable.class, { :foo => :bar })
      @creeper.creepables_relation(@creepable.class, { :foo => :bar })
    end
  end

  describe "#creepees_relation" do
    it "calls $Creep.creepables_relation" do
      expect($Creep).to receive(:creepables_relation).with(@creeper, @creepable.class, { :foo => :bar })
      @creeper.creepees_relation(@creepable.class, { :foo => :bar })
    end
  end

  describe "deleting a creeper" do
    before(:all) do
      @creeper = ImACreeper.create
      @creeper.creep!(@creepable)
    end

    it "removes creep relationships" do
      expect(Socialization.creep_model).to receive(:remove_creepables).with(@creeper)
      @creeper.destroy
    end
  end

end
