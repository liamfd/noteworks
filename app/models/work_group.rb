class WorkGroup < ActiveRecord::Base
  belongs_to :user
  has_many :works, foreign_key: :group_id

end
