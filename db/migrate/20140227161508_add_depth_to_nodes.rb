class AddDepthToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :depth, :integer
  end
end
