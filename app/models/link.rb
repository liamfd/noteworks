class Link < ActiveRecord::Base
  belongs_to :child, class_name: :Node
  belongs_to :parent, class_name: :Node

  belongs_to :work
  belongs_to :link_collection, inverse_of: :links
 # validates :work_id, presence: true

  def as_json(*args)
    {
    source: "#{parent.id}",
    target: "#{child.id}",
    weight: "#{1}"
    }
  end

  def change_child(new_child)
    self.update_attributes(child_id: new_child.id)
  end

  def change_parent(new_parent)
    self.update_attributes(parent_id: new_parent.id)
  end
end
