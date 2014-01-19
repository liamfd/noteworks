class AddCombinedNotesToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :combined_notes, :text
  end
end
