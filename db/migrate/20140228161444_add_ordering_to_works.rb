class AddOrderingToWorks < ActiveRecord::Migration
  def change
    add_column :works, :ordering, :text
  end
end
