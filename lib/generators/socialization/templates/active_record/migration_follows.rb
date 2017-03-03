class CreateCreeps < ActiveRecord::Migration
  def change
    create_table :creeps do |t|
      t.string  :creeper_type
      t.integer :creeper_id
      t.string  :creepable_type
      t.integer :creepable_id
      t.datetime :created_at
    end

    add_index :creeps, ["creeper_id", "creeper_type"],     :name => "fk_creeps"
    add_index :creeps, ["creepable_id", "creepable_type"], :name => "fk_creepables"
  end
end
