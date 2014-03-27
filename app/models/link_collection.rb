class LinkCollection < ActiveRecord::Base
  belongs_to :node, inverse_of: :link_collections
  belongs_to :work, inverse_of: :link_collections
  has_many :links, inverse_of: :link_collection, dependent: :destroy

  def set_links(text)
  	chunks = text.split(",")
  	chunks.each do |chunk|

      #perhaps have this find all of them
  		child_node = Node.find_by(title: chunk.strip)

      if child_node == nil #if the child doesn't exist, create it at the very end
        place = self.work.get_ordering.length
        self.work.add_new_element([place], [".,"+chunk])
        child_node = self.work.get_element_in_ordering(place, self.work.get_ordering)
      end
  
      link = self.links.build
      #if it has a parent, give the link that parent. otherwise, set it to nil
      if self.node != nil
        link.parent_id = self.node.id
      else
        link.parent_id = nil
      end
      link.child = child_node
    	link.save
    
	  end
  end

end
