class CreateLinkCollections < ActiveRecord::Migration
  def change
    create_table :link_collections do |t|
      t.references :node, index: true

      t.timestamps
    end
  end
end
