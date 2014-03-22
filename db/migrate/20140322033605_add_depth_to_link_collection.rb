class AddDepthToLinkCollection < ActiveRecord::Migration
  def change
    add_column :link_collections, :depth, :integer
  end
end
