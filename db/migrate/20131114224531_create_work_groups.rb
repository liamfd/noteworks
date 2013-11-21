class CreateWorkGroups < ActiveRecord::Migration
  def change
    create_table :work_groups do |t|
      t.references :user, index: true

      t.timestamps
    end
  end
end
