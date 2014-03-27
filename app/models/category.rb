class Category < ActiveRecord::Base
	has_many :nodes
	belongs_to :work

    before_save :color_randomizer

    def before_destroy
    	binding.pry
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
