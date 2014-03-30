class CreatePlaceHolders < ActiveRecord::Migration
  def change
    create_table :place_holders do |t|
      t.references :work, index: true
      t.string :text
      t.integer :depth

      t.timestamps
    end
  end
end
