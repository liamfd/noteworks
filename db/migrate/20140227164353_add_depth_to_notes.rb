class AddDepthToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :depth, :integer
  end
end
