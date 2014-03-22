class AddWorkToLinkCollections < ActiveRecord::Migration
  def change
    add_reference :link_collections, :work, index: true
  end
end
