class AddNameToWorkGroup < ActiveRecord::Migration
  def change
    add_column :work_groups, :name, :string
  end
end
