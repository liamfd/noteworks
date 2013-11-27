class Work < ActiveRecord::Base
  belongs_to :group

  has_many :nodes, dependent: :destroy

	def parseText
		Node.destroy_all(work_id: self.id)
		Struct.new("NodeDepth", :node_idnum, :depth)
		@stack = Array.new


		markup.each_line do |line|
			#puts "\n--------\n"
			#parser rules: any amount of whitespace followed immediately by < means new node. Otherwise, new note.
			#<TYPE.CATEGORY>TITLE
			#if the occurence of <*> is before the first occurence of " then it's a new
			#@angleBracketLocation = line.index(/[ ,\t]*<.*>/)
			@firstChar = line.match(/[ ,\t]*(.)/).captures.first

			#if a new node should be made
			if @firstChar == '<'
				
				@withinBrackets = line.match(/<.*>/).to_s
				#puts @withinBrackets

				#get type, convert it to a constant
				@type = @withinBrackets.match(/<(.*)\./).captures.first
				@type[0] = @type[0].capitalize
				@type = (@type + "Node")
				#puts @type
				@const_type = @type.constantize
				@new_node = @const_type.new()

				#get the category string, use it to pull a category id
				#puts @category
				@category = @withinBrackets.match(/\.(.*)>/).captures.first
				@category_id = (Category.where("name = ?", @category).first).id
				@new_node.category_id = @category_id

				@title = line.match(/>(.*)/).captures.first
				@title = @title.strip
				#puts @title
				@new_node.title = @title

				@new_node.work_id = self.id
				@new_node.save


				#get the parent.
				@whitespace = line.match(/(.*)</).captures.first
				#puts @whitespace.length #should round this up to the nearest 3, resave it somehow, to make it clear
				@depth = (@whitespace.length)/3

				@newNodeDepth = Struct::NodeDepth.new(@new_node.id, @depth)
				if @depth == 0
					@stack.push(@newNodeDepth)
				else
					@currNodeDepth = @stack.pop
					while @depth <= @currNodeDepth.depth do #while you're less deep, therefore it aint yo momma 
						@currNodeDepth = @stack.pop
					end #at this point, @currNodeDepth is the nearest element that's not as deep as the new one, it's parent
					@parentNode = Node.find(@currNodeDepth.node_idnum)

					@relation = ParentChild.new(child_id: @new_node.id, parent_id:@parentNode.id)
					@relation.save
					@new_node.parent_relationships << @relation
					@parentNode.child_relationships << @relation

					#@new_node.parent_relationships.build(child_id: @new_node.id, parent_id:@parentNode.id)
					#@new_node.parents << @parentNode
					
					@stack.push(@currNodeDepth)#push the parent back in, in case it has siblings
					@stack.push(@newNodeDepth)#push self in, in case it has children

					#@parent_node.child=
					#make this nodes id into the parents child.
					#make the child's parent the parentNode's id.
				end

				#somehow have to break this up such that it says 3 whitespace = 1 tab. 
				#ah, but the javascript will do that for me.

			end
		end
	end

end