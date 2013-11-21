class Category < ActiveRecord::Base
	has_many :nodes

	validates :name, presence: true
end
