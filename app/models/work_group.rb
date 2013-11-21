class WorkGroup < ActiveRecord::Base
  belongs_to :user
  has_many :works

end
