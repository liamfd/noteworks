class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
  has_many :notes, dependent: :destroy
  has_one :position, dependent: :destroy

  has_many :child_relationships, class_name: :ParentChild
  has_many :children, through: :child_relationships

  has_many :parent_relationships, class_name: :ParentChild
  has_many :parents, through: :parent_relationships

  validates :category_id, presence: true
  validates :work_id, presence: true
end
