class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.text :markup
      t.references :group, index: true

      t.timestamps
    end
  end
end
