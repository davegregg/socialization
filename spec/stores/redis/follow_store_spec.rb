require 'spec_helper'

describe Socialization::RedisStores::Creep do
  before do
    use_redis_store
    @klass = Socialization::RedisStores::Creep
    @base = Socialization::RedisStores::Base
  end

  describe "method aliases" do
    it "should be set properly and made public" do
      # TODO: Can't figure out how to test method aliases properly. The creeping doesn't work:
      # assert @klass.method(:creep!) == @base.method(:relation!)
      expect(:creep!).to be_a_public_method_of(@klass)
      expect(:uncreep!).to be_a_public_method_of(@klass)
      expect(:creeps?).to be_a_public_method_of(@klass)
      expect(:creepers_relation).to be_a_public_method_of(@klass)
      expect(:creepers).to be_a_public_method_of(@klass)
      expect(:creepables_relation).to be_a_public_method_of(@klass)
      expect(:creepables).to be_a_public_method_of(@klass)
      expect(:remove_creepers).to be_a_public_method_of(@klass)
      expect(:remove_creepables).to be_a_public_method_of(@klass)
    end
  end

end
