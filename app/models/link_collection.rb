class LinkCollection < ActiveRecord::Base
  belongs_to :node, inverse_of: :link_collections
  has_many :links, inverse_of: :link_collection, dependent: :destroy

  def set_links(text)
  	
  	chunks = text.split(",")
  	chunks.each do |chunk|
  		n = Node.find_by(title: chunk)
      if n != nil#if there's an actual link there
        link = self.links.build
      	#link.link_collection_id = self.id
      	link.parent_id = self.node.id
        link.child_id = n.id
      	link.save
      end
	  end
  #	self.links << link
  end

end
