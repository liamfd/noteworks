class CreateParentChildren < ActiveRecord::Migration
  def change
    create_table :parent_children do |t|
      t.references :child, index: true
      t.references :parent, index: true

      t.timestamps
    end
  end
end
