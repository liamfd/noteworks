class Node < ActiveRecord::Base
  belongs_to :category
  belongs_to :work
end
