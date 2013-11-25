class ParentChild < ActiveRecord::Base
  belongs_to :child, class_name: :Node
  belongs_to :parent, class_name: :Node
end
