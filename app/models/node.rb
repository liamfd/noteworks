class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
  has_many :notes, dependent: :destroy
  has_one :position, dependent: :destroy

  validates :category_id, presence: true
  validates :work_id, presence: true

  has_many :child_relationships, class_name: "ParentChild", foreign_key: 'child_id'
  has_many :parent_relationships, class_name: "ParentChild", foreign_key: 'parent_id'

  has_many :children, through: :child_relationships, source: 'parent'
  has_many :parents, through: :parent_relationships, source: 'child'

  belongs_to :node, class_name: "Node"
end
