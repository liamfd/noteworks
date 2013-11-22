class AddNameToWork < ActiveRecord::Migration
  def change
    add_column :works, :name, :string
  end
end
