class RemoveMarkupFromWork < ActiveRecord::Migration
  def change
    remove_column :works, :markup, :string
  end
end
