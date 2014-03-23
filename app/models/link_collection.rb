class LinkCollection < ActiveRecord::Base
  belongs_to :node, inverse_of: :link_collections
  has_many :links, inverse_of: :link_collection, dependent: :destroy

  def set_links(text)
  	chunks = text.split(",")
  	chunks.each do |chunk|

  		n = Node.find_by(title: chunk.strip)

      if n != nil#if there's an actual link there
        link = self.links.build
        #if it has a parent, give the link that parent. otherwise, set it to nil
        if self.node != nil
          link.parent_id = self.node.id
        else
          link.parent_id = nil
        end
        link.child_id = n.id
      	link.save
      end
	  end
  end

end
