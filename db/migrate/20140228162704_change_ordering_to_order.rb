class ChangeOrderingToOrder < ActiveRecord::Migration
  def change
  	rename_column :works, :ordering, :order
  end
end
