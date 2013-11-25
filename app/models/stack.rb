class Stack < ActiveRecord::Base

	after_initialize :makeArray

	def makeArray
		@store = Array.new
	end

	def pop
		if empty?
			nil
		else
			@store.pop
		end
	end

	def push(element)
		if element.nil?
			nil
		else
			@store.push(element)
			self
		end
	end

	def size
		@store.size
	end

	def empty?
		size == 0
	end
end
