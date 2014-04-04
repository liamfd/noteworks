class Category < ActiveRecord::Base
  has_many :nodes
  belongs_to :work

  before_save :color_randomizer
  before_destroy :set_nodes_category_to_default

  validates :name, uniqueness: true

  def set_nodes_category_to_default
    if work!=nil
      default_category = work.categories.find_by name: ""
      move_nodes(default_category)
    end
  end

  #bottom, private
  def color_randomizer
    if self.color == nil || self.color == ""
      self.color = "#" + "%02x" % (rand * 0x99) + "%02x" % (rand * 0x99) + "%02x" % (rand * 0x99)
    end
  end

  def merge_with_category(merge_to_name)
    merge_to = work.categories.find_by name: merge_to_name
    move_nodes(merge_to)
    self.delete
  end

  def move_nodes(new_owner)
    self.nodes.each do |node|
      node.update_attributes(category: new_owner)
    end
  end


end
