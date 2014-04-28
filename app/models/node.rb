class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
  has_many :notes, dependent: :destroy, inverse_of: :node
  has_one :position, dependent: :destroy
  has_many :link_collections, inverse_of: :node

  validates :work_id, presence: true

  has_many :child_relationships, class_name: "Link", foreign_key: 'parent_id', dependent: :destroy
  has_many :parent_relationships, class_name: "Link", foreign_key: 'child_id', dependent: :destroy

  has_many :children, through: :child_relationships, source: 'child'
  has_many :parents, through: :parent_relationships, source: 'parent'

  belongs_to :node, class_name: "Node"

  def combine_notes_in_order
    ordering = work.get_ordering
    location = -1

    ordering.each_with_index do |element, i|
      if element.id.to_i == id && element.model == "Node"
        location = i
      end
    end

    if location != -1
      children = self.work.find_element_children(location, self.depth, ordering)
    end
  
    combined = ""
    children.each do |child|
      if child[:node].is_a?(Note)
        new_piece = " //- " << child[:node].body.strip
        combined << new_piece
      end
    end
    #update_attributes(combined_notes: combined)
    return combined
  end

  def to_cytoscape_hash
    #add section
    toNode = {};
    toNode[:id] = self.id
    toNode[:title] = self.title
    toNode[:notes] = self.combine_notes_in_order
    toNode[:color] = self.category.color
   # toNode[:id] = self.id
    #toNode[:title] = self.title

    toEdges = []

    pars = []
    pars << self.parent_relationships
    kids = []
    kids << self.child_relationships
    rels = (pars << kids).flatten
        #this is where the error is coming from. was resetting parent_relationships to null. ask why.
    #relations = (self.parent_relationships << self.child_relationships).flatten
    toEdges = rels.map do |r|
      {id: r.id, source: r.parent_id.to_s, target: r.child_id.to_s}
    end
    
    toReturn = {}
    toReturn[:node] = toNode
    toReturn[:edges] = toEdges
    return toReturn
  end


  #adds a single note to the end of the current combined_notes string
  def old_add_note_to_combined(new_note)
    new_piece = " //- " << new_note.body.strip
    combined = self.combined_notes + new_piece
    #puts @combined
    self.update_attribute(:combined_notes, combined);
    self.reload
  end

  #generates combined_notes from all of the current notes
  def old_combine_notes
    notes = self.notes
    full_text = ""

    for note in notes
      full_text << " //- "
      full_text << note.body.strip
     # if @note != @notes[-1]
      #  @full_text << " //- "
     # end
    end

    self.combined_notes = full_text
    puts self.combined_notes
    self.save 
  end



end