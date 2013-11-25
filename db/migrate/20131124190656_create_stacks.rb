class CreateStacks < ActiveRecord::Migration
  def change
    create_table :stacks do |t|
      t.integer :size

      t.timestamps
    end
  end
end
