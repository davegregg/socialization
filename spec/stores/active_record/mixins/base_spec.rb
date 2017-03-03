require 'spec_helper'

describe Socialization::ActiveRecordStores::Mixins::Base do
  describe ".update_counter" do
    it "increments counter cache if column exists" do
      creepable = ImACreepableWithCounterCache.create

      update_counter(creepable, creepers_count: +1)

      expect(creepable.reload.creepers_count).to eq(1)
    end

    it "does not raise any errors if column doesn't exist" do
      creepable = ImACreepable.create
      update_counter(creepable, creepers_count: +1)
    end
  end

  def update_counter(model, counter)
    klass = Object.new
    klass.extend(Socialization::ActiveRecordStores::Mixins::Base)
    klass.update_counter(model, counter)
  end
end

