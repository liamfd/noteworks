class Category < ActiveRecord::Base
  has_many :nodes
  belongs_to :work

  before_save :color_randomizer
  before_destroy :set_nodes_category_to_default

  validates :name, uniqueness: true

  def set_nodes_category_to_default
    default_category = work.categories.find_by name: ""
    self.nodes.each do |node|
      node.update_attributes(category: default_category)
    end
  end

  #bottom, private
  def color_randomizer
    if self.color == nil
      self.color ||= "#" + "%02x" % (rand * 0x99) + "%02x" % (rand * 0x99) + "%02x" % (rand * 0x99)
    end
  end

end
