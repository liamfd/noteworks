class Category < ActiveRecord::Base
	has_many :nodes
	belongs_to :work

    before_save :color_randomizer

	#bottom, private
   def color_randomizer
   		self.color ||= "#" + "%06x" % (rand * 0xffffff)
   end
end
