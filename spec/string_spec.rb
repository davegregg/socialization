require 'spec_helper'

describe String do
  describe "#deep_const_get" do
    it "should return a class" do
      expect("Socialization".deep_const_get).to eq(Socialization)
      expect("Socialization::ActiveRecordStores".deep_const_get).to eq(Socialization::ActiveRecordStores)
      expect("Socialization::ActiveRecordStores::Creep".deep_const_get).to eq(Socialization::ActiveRecordStores::Creep)

      expect { "Foo::Bar".deep_const_get }.to raise_error(NameError)
    end
  end
end
