class ParentChild < ActiveRecord::Base
  belongs_to :child, class_name: :node
  belongs_to :parent, class_name: :node
end
