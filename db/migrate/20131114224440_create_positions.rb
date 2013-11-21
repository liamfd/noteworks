class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :x
      t.integer :y
      t.integer :size
      t.references :node, index: true

      t.timestamps
    end
  end
end
