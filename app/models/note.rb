class Note < ActiveRecord::Base
  belongs_to :node, inverse_of: :notes
end
