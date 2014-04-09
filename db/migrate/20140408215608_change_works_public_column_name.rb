class ChangeWorksPublicColumnName < ActiveRecord::Migration
  def change
		rename_column :works, :public, :show_others
  end
end
