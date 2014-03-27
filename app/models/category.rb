class Category < ActiveRecord::Base
	has_many :nodes
	belongs_to :work

    before_save :color_randomizer
    before_destroy :set_nodes_category_to_default

    def set_nodes_category_to_default
    	default_category = work.categories.find_by name: ""
    	self.nodes.each do |node|
    		node.update_attributes(category: default_category)
    	end
    end

	#bottom, private
   def color_randomizer
   		self.color ||= "#" + "%06x" % (rand * 0xffffff)
   end
end
