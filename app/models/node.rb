class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
  has_many :notes, dependent: :destroy
  has_one :position, dependent: :destroy

  validates :category_id, presence: true
  validates :work_id, presence: true

  has_many :child_relationships, class_name: "Link", foreign_key: 'parent_id', dependent: :destroy
  has_many :parent_relationships, class_name: "Link", foreign_key: 'child_id', dependent: :destroy

  has_many :children, through: :child_relationships, source: 'child'
  has_many :parents, through: :parent_relationships, source: 'parent'

  belongs_to :node, class_name: "Node"

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
    puts self.combined_notes
    self.save 
  end

end