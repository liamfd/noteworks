class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :node, index: true
      t.text :body

      t.timestamps
    end
  end
end
