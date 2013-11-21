class Work < ActiveRecord::Base
  belongs_to :work_group
  has_many :nodes, dependent: :destroy
end
