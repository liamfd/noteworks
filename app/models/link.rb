class Link < ActiveRecord::Base
  belongs_to :child, class_name: :Node
  belongs_to :parent, class_name: :Node

  belongs_to :work
  #validates :work_id, presence: true

  def as_json(*args)
    {
    source: "#{parent.id}",
    target: "#{child.id}",
    weight: "#{1}"
    }
  end
end
