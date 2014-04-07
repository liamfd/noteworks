class AddPublicToWorks < ActiveRecord::Migration
  def change
    add_column :works, :public, :boolean
  end
end
