class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
  has_many :notes, dependent: :destroy, inverse_of: :node
  has_one :position, dependent: :destroy

  validates :category_id, presence: true
  validates :work_id, presence: true

  has_many :child_relationships, class_name: "Link", foreign_key: 'parent_id', dependent: :destroy
  has_many :parent_relationships, class_name: "Link", foreign_key: 'child_id', dependent: :destroy

  has_many :children, through: :child_relationships, source: 'child'
  has_many :parents, through: :parent_relationships, source: 'parent'

  belongs_to :node, class_name: "Node"

  #adds a single node to the end of the current combined_notes string
  def add_note_to_combined(new_note)
    @new_piece = " //- " << new_note.body.strip
    @combined = self.combined_notes + @new_piece
    puts @combined
    self.update_attribute(:combined_notes, @combined);
    self.reload
  end

  #generates combined_notes from all of the current notes
  def combine_notes
    @notes = self.notes
    @full_text = ""
    

    for @note in @notes
      @full_text << " //- "
      @full_text << @note.body.strip
     # if @note != @notes[-1]
      #  @full_text << " //- "
     # end
    end

    #IMPROVE: HAVE THIS RETURN full_text, THEN JUST SAVE IT WITH A CALLBACK PERHAPS?
    self.combined_notes = @full_text
   # puts self.combined_notes
    self.save 
  end

end