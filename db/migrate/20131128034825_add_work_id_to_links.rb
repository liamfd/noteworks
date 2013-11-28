class AddWorkIdToLinks < ActiveRecord::Migration
  def change
    add_column :links, :work_id, :integer
  end
end
