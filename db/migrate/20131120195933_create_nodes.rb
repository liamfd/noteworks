class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :title
      t.references :category, index: true
      t.references :work, index: true

      t.timestamps
    end
  end
end
