class AddWorkToCategory < ActiveRecord::Migration
  def change
    add_reference :categories, :work, index: true
  end
end
