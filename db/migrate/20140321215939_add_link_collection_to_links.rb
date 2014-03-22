class AddLinkCollectionToLinks < ActiveRecord::Migration
  def change
    add_reference :links, :link_collection, index: true
  end
end
