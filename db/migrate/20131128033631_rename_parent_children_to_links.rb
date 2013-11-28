class RenameParentChildrenToLinks < ActiveRecord::Migration
  def self.up
  	rename_table :parent_children, :links 
  end
  def self.down
  	rename_table :links, :parent_children
  end
end
