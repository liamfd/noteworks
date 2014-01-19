class AddEmptyStringToCombinedNotes < ActiveRecord::Migration
  def change
    change_column :nodes, :combined_notes, :text, :default => ""
  end
end