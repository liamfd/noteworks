class Work < ActiveRecord::Base
  belongs_to :group

  has_many :nodes, dependent: :destroy

	def parseText
		Node.destroy_all(work_id: self.id)
		Struct.new("NodeDepth", :node_id, :depth)


		markup.each_line do |line|
			puts "\n--------\n"
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			puts line
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
			@firstChar = line.match(/[ ,\t]*(.)/).captures.first
			if @firstChar == '<' #if a new node should be made
				puts "Nailed it. Making a new one."

				@withinBrackets = line.match(/<.*>/).to_s
				puts @withinBrackets

				#get type, convert it to a constant
				puts @type
				@type = @withinBrackets.match(/<(.*)\./).captures.first
				@type[0] = @type[0].capitalize
				@type = (@type + "Node")
				@const_type = @type.constantize
				@new_node = @const_type.new()



				#get the parent.
				@whitespace = line.match(/(.*)</).captures.first
				puts ":" + @whitespace + ":"
				puts @whitespace.length #should round this up to the nearest 3, resave it somehow, to make it clear
				@depth = (@whitespace.length)/3
				Struct::NodeDepth.new(@new_node.id, @depth)


				#somehow have to break this up such that it says 3 whitespace = 1 tab. 
				#ah, but the javascript will do that for me.

				#make an array of structs, containing element id's and depth, which corresponds to 1 for 3 whitespace
				#if your numspaces is greater than the one on top of the stack, push yours, you're a child
				#if it's less, you're an aunt, or great aunt, etc. they got no more kids. pop the top, push yours
				#if it's the same, you're a sibling, they got no more kids. pop the top, push yours.



				#get the category string, use it to pull a category id
				puts @category
				@category = @withinBrackets.match(/\.(.*)>/).captures.first
				@category_id = (Category.where("name = ?", @category).first).id
				puts @category_id
				@new_node.category_id = @category_id

				@title = line.match(/>(.*)/).captures.first
				puts @title
				@new_node.title = @title

				@new_node.work_id = self.id
				@new_node.save
			end
		end
	end

end