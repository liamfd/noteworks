class Work < ActiveRecord::Base
  belongs_to :group

  has_many :nodes, dependent: :destroy

	def parseText
		markup.each_line do |line|
			puts "\n--------\n"
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			puts line
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
			@firstChar = line.match(/[ ,\t]*(.)/).captures.first
			if @firstChar == '<'
				puts "Nailed it. Making a new one."
				@withinBrackets = line.match(/<.*>/).to_s
				puts @withinBrackets

				#get type, convert it to a constant
				puts @type
				@type = @withinBrackets.match(/<(.*)\./).captures.first
				@type[0] = @type[0].capitalize
				@type = (@type + "Node")
				@const_type = @type.constantize

				puts @category
				@category = @withinBrackets.match(/\.(.*)>/).captures.first
				@category_id = (Category.where("name = ?", @category).first).id
				puts @category_id
				
				@title = line.match(/>(.*)/).captures.first
				puts @title

				@new_node = @const_type.new()
				@new_node.category_id = @category_id
				@new_node.title = @title
				@new_node.work_id = self.id
				@new_node.save
			end
		end
	end

end