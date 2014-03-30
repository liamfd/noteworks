class PlaceHolder < ActiveRecord::Base
  belongs_to :work
  before_create :init_depth

  def init_depth
  	if self.depth == nil
  		self.depth = 0
  	end
  end 

end
